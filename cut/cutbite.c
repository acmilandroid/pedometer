#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define	MAX_DATA	54000	/* one hour at 15 Hz */
#define	MAX_BITES	500
#define	CUT		    (15*30)	/* 30 sec at 15 Hz */
#define	MAX_WINDOWS	20000

int main(int argc, char *argv[])

{
FILE	*fpt;
char	filename[320];
int	i,j,k;
float	zero[3],total;
float	yaw,pitch,roll;
float	*Data[7],*SmoothedData[7];
int	TotalData;
int	GTBiteIndex[MAX_BITES];		/* data index of GT bite */
char	GTBiteHand[MAX_BITES][16];	/* left, right or both */
char	GTBiteUtensil[MAX_BITES][16];	/* fork, hand, spoon, chopsticks */
char	GTBiteContainer[MAX_BITES][16];	/* plate, bowl, mug, glass */
char	GTBiteFood[MAX_BITES][320];	/* anything */
int	BiteNumber,TotalGTBites;
int	TotalWindows,WindowIndex[MAX_WINDOWS];
int	WindowBites[MAX_WINDOWS];
float	FloatWindowBites[MAX_WINDOWS];
int	BiteLength,BiteStart,BiteEnd;
int	start,end;

if (argc != 2)
  {
  printf("Usage:  cutwindows [filename.txt]\n");
  printf("        assumes there is a gt_union.txt in same folder\n");
  exit(0);
  }

for (i=0; i<7; i++)
  {
  Data[i]=(float *)calloc(MAX_DATA,sizeof(float));
  SmoothedData[i]=(float *)calloc(MAX_DATA,sizeof(float));
  }

if ((fpt=fopen(argv[1],"rb")) == NULL)
  {
  printf("Unable to open %s for reading\n",argv[1]);
  exit(0);
  }

	/* read data file, determine total amount of data */
TotalData=0;
  	/* file format is x y z (accel units are volts)
	** yaw pitch roll (gyro units are volts) scale (units are grams) */
zero[0]=zero[1]=zero[2]=0.0; /* used to calculate avg of yaw pitch roll */
while (1)
  {
  i=fscanf(fpt,"%f %f %f  %f %f %f  %f",
	&(Data[0][TotalData]),&(Data[1][TotalData]),
	&(Data[2][TotalData]),	/* x y z */
	&(Data[3][TotalData]),&(Data[4][TotalData]),
	&(Data[5][TotalData]),	/* yaw pitch roll */
	&(Data[6][TotalData]));	/* scale */
  if (i != 7)
    break;
  for (j=0; j<3; j++)
    zero[j]+=Data[j+3][TotalData];
  TotalData++;
  }
fclose(fpt);

for (j=0; j<3; j++)
  zero[j]/=(float)TotalData;

	/* convert data voltages to deg/sec (gyros)
	** and gravities (accelerometers) 
	** gyro=LPY410al, 2.5mv per deg/sec, zero-point found
	** by calculating the average data value of the whole recording
	** accel=LIS344alh, Vdd=3.3v, 5/3.3=1.515 gravities per volt */
for (i=0; i<TotalData; i++)
  {
	/* 3.3v supply so 1/2(3.3)=1.65 reference */
	/* 15/3.3=4.5454 instead, if chip wired to +-6g */
  for (j=0; j<3; j++)
    Data[j][i]=(Data[j][i]-1.65)*(5.0/3.3);
	/* reference voltage calculated as average ADC value for while file */
  for (j=3; j<6; j++)
    Data[j][i]=(Data[j][i]-zero[j-3])*400.0;
  }

	/* smooth the data */
for (i=0; i<7; i++)
  for (j=0; j<7; j++)
    SmoothedData[j][i]=Data[j][i];
for (i=TotalData-7; i<TotalData; i++)
  for (j=0; j<7; j++)
    SmoothedData[j][i]=Data[j][i];
for (i=7; i<TotalData-7; i++)
  {
  for (j=0; j<7; j++)
    {	/* averaging over a 1-sec window (15 samples) centered on the datum */
    total=0.0;
    for (k=i-7; k<=i+7; k++)
    if (k >= 0  &&  k < TotalData)
      total+=Data[j][k];
    SmoothedData[j][i]=total/15.0;
    }
  } 

	/* load GT bites */
strcpy(filename,argv[1]);
j=strlen(filename)-1;
while (j > 0  &&  filename[j] != '/'  &&  filename[j] != '\\')
  j--;
filename[j+1]=0;
strcat(filename,"gt_union.txt");
if ((fpt=fopen(filename,"r")) == NULL)
  {
  printf("Unable to open %s for reading\n",filename);
  exit(0);
  }
TotalGTBites=0;
while (1)
  {
  i=fscanf(fpt,"%d  %d  %s %s %s %s",
	&BiteNumber,&(GTBiteIndex[TotalGTBites]),
	GTBiteHand[TotalGTBites],GTBiteUtensil[TotalGTBites],
	GTBiteContainer[TotalGTBites],GTBiteFood[TotalGTBites]);
  if (i != 6)
    break;
  TotalGTBites++;
  }
fclose(fpt);

	/* cut windows 10 sec prior to first bite, to 10 sec after last bite */
start=GTBiteIndex[0]-(30*15);
if (start < 0) {
    while (start < 0) {
        printf("0 0 0 0 0");
        start++;
    }
}
end=GTBiteIndex[TotalGTBites-1]+(30*15);
if (end >= TotalData)
  end=TotalData-1;

TotalWindows=0;
for (i=start; i<end; i+=15) // CUT)
  {
  if (i+CUT > end)
    break;	/* not a full window */
  WindowIndex[TotalWindows]=i;
  WindowBites[TotalWindows]=0;
  FloatWindowBites[TotalWindows]=0.0;
  for (j=0; j<TotalGTBites; j++)
    {
    if (GTBiteIndex[j] >= i  &&  GTBiteIndex[j] < i+CUT)
    {
      WindowBites[TotalWindows]++;
    }
  if (WindowBites[TotalWindows] > 5)
    WindowBites[TotalWindows]=6;	/* cap it at 6; these are infrequent */
  if (0) // do not need to cap?   FloatWindowBites[TotalWindows] > 6.0)
    FloatWindowBites[TotalWindows]=6.0;	/* cap it at 6; these are infrequent */
  TotalWindows++;
  }

	/* print out cut bite data */
if (1)
for (i=0; i<TotalWindows; i++)
  {
  if (0)
    printf("%d...%d -> %d\n",WindowIndex[i],WindowIndex[i]+CUT,WindowBites[i]);
  else if (0)
    printf("%d...%d -> %d\n",WindowIndex[i],WindowIndex[i]+CUT,
		WindowBites[i]);
  else
    {
    printf("%d",WindowBites[i]);	/* class is #bites */
    for (k=WindowIndex[i]; k<WindowIndex[i]+CUT; k++)
      {
      for (j=0; j<6; j++)
        printf("\t%.3f",SmoothedData[j][k]);
      }
    printf("\n");
    }
  }

	/* write out binary data */
if (0)
  {
  fpt=fopen("win.bin","wb");
  for (i=0; i<TotalWindows; i++)
    {
    fwrite(&(WindowBites[i]),4,1,fpt);
    for (k=WindowIndex[i]; k<WindowIndex[i]+CUT; k++)
      {
      for (j=0; j<6; j++)
        fwrite(&(SmoothedData[j][k]),4,1,fpt);
      }
    }
  fclose(fpt);
  }

for (i=0; i<7; i++)
  {
  free(Data[i]);
  free(SmoothedData[i]);
  }

}