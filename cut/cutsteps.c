/********************************************************************************
 * This program reads a pedometer data file and cuts out windows
 *  of steps. Step indices are determined via steps.txt.
 * 
 * The data is cut from 5 sec prior to first step to 10 sec after
 * last step.  Each window is 5 sec.
 * 
 * Usage: ./cutsteps [window_size] [window_stride] [pedometer_data_filename.csv] [steps.txt]
 * 
 * CUT is the window size in datum (each second is 15 datum)
 * STRIDE is the amount of datum to slide the window each time
 * Output is printed to stdout, needs to be piped to a file
 ********************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define	MAX_DATA            54000	//one hour at 15 Hz
#define	MAX_STEPS           10000   //maximum number of steps
#define SMOOTHING           7       //smoothing window
#define	MAX_WINDOWS         30000
#define DATA_FIELDS         3		//number of different sensors being used
#define TOTAL_DATA_FIELDS   17
#define DEBUG               0       //debug modes 1 and 2 for alternate prints
#define PRINT               1       //print data
#define SAMPLES_PER_STEP    7       //number of samples used per step


int main(int argc, char *argv[]) {
    FILE	*fpt;
    char	trash[100];
    int		start, end, i, j, k;
    float	total;
    float	**Data, **SmoothedData;
    int		totalData, totalSteps, totalWindows;
    int		*windowIndex, *windowSteps;
    int     *GTstepIndex;
    float   *floatWindowSteps;
    int     firstStep, lastStep;

    //allocate space for everything
    Data = (float **)calloc(sizeof(float *), DATA_FIELDS);
    for (i = 0; i < DATA_FIELDS; i++) {
        Data[i] = (float *)calloc(sizeof(float), MAX_DATA);
    }
    SmoothedData = (float **)calloc(sizeof(float *), DATA_FIELDS);
    for (i = 0; i < DATA_FIELDS; i++) {
        SmoothedData[i] = (float *)calloc(sizeof(float), MAX_DATA);
    }
    windowIndex = (int *)calloc(sizeof(int), MAX_WINDOWS);
    windowSteps = (int *)calloc(sizeof(int), MAX_WINDOWS);
    floatWindowSteps = (float *)calloc(sizeof(int), MAX_WINDOWS);

    if (argc != 5) {
        printf("Usage: ./cutsteps [window_size] [window_stride] [pedometer_data_filename.csv] [steps.txt]\n");
        exit(0);
    }

    if ((fpt=fopen(argv[3], "rb")) == NULL) {
        printf("Unable to open %s for reading\n", argv[3]);
        exit(0);
    }

    int CUT = atoi(argv[1]);
    int STRIDE = atoi(argv[2]);

    // read data file, determine total amount of data
    totalData = 0;

    //scan and throw away header information
    for (i = 0; i < 2*TOTAL_DATA_FIELDS + 6; i++) {
        fscanf(fpt, "%s", trash);
    }

	//scan acceleration data
    while (
        fscanf(fpt,"%s %s %s %s %s %s %s %s %s %s %f %f %f %s %s %s %s",
            trash, //timestamp
            trash, //realtime
            trash, //GSR
            trash, //QuatW
            trash, //QuatX
            trash, //QuatY
            trash, //QuatZ
            trash, //GyroX
            trash, //GyroY
            trash, //GyroZ
            &(Data[0][totalData]), //AccelX
            &(Data[1][totalData]), //AccelY
            &(Data[2][totalData]), //AccelZ
            trash, //MagX
            trash, //MagY
            trash, //MagZ
            trash) //DateTime
        == TOTAL_DATA_FIELDS)
    {
        totalData++;
    }
	
	fclose(fpt);

	/* convert data voltages to deg/sec (gyros)
	** and gravities (accelerometers) 
	** gyro=LPY410al, 2.5mv per deg/sec, zero-point found
	** by calculating the average data value of the whole recording
	** accel=LIS344alh, Vdd=3.3v, 5/3.3=1.515 gravities per volt */
    // for (i = 0; i < totalData; i++) {
    //         /* 3.3v supply so 1/2(3.3)=1.65 reference */
    //         /* 15/3.3=4.5454 instead, if chip wired to +-6g */
    //     for (j = 0; j < 3; j++) {
    //         Data[i][j]=(Data[i][j]-1.65)*(5.0/3.3);
    //     }
    //     /* reference voltage calculated as average ADC value for while file */
    //     for (j = 3; j < 6; j++) {
    //         Data[i][j]=(Data[i][j]-zero[j-3])*400.0;
    //     }
    // }

	// fill beginning and end without smoothing
	for (i = 0; i < SMOOTHING; i++) {
		for (j = 0; j < DATA_FIELDS; j++) {
			SmoothedData[j][i] = Data[j][i];
		}
	}
	for (i = totalData - SMOOTHING; i < totalData; i++) {
		for (j = 0; j < DATA_FIELDS; j++) {
			SmoothedData[j][i] = Data[j][i];
		}
	}	

	// smooth data
	// for (i = SMOOTHING; i < totalData - SMOOTHING; i++) {
	// 	/* averaging over a 1-sec window (15 samples) centered on the datum */
	// 	for (j = 0; j < DATA_FIELDS; j++) {
	// 		total = 0.0;
	// 		for (k = i - SMOOTHING; k <= i + SMOOTHING; k++) {
	// 			if (k >= 0  &&  k < totalData) total += Data[j][k];
	// 		}			
	// 		SmoothedData[j][i] = total / (SMOOTHING*2 + 1);
	// 	}
	// }

	// load steps.txt
	if ((fpt=fopen(argv[4], "rb")) == NULL) {
		printf("Unable to open %s for reading\n", argv[4]);
		exit(0);
	}
	
	// allocate space for ground truth data
	char** foot = malloc(sizeof(char*) * MAX_STEPS);
	for (i = 0; i < MAX_STEPS; i++) {
		foot[i] = malloc(sizeof(char) * 10);
	}
	GTstepIndex = malloc(sizeof(int) * MAX_STEPS);

	// read step ground truth file
	totalSteps = 0;
    firstStep = MAX_DATA;
    lastStep = -1;
	while (fscanf(fpt, "%d %s", &(GTstepIndex[totalSteps]), foot[totalSteps]) == 2) {
		//if (strlen(foot[totalSteps]) != 1) break; //excludes ledge and redge shifts
        //find min and max step index
        if (firstStep > GTstepIndex[totalSteps]) firstStep = GTstepIndex[totalSteps];
        if (lastStep < GTstepIndex[totalSteps]) lastStep = GTstepIndex[totalSteps];
		totalSteps++;
	}
	fclose(fpt);

	/* cut windows CUT datum prior to first step, to CUT+STRIDE datum after last step */
	start = firstStep - CUT;
	end = lastStep + CUT + STRIDE;

    if (DEBUG) {
        printf("start: %d\n", start);
        printf("end: %d\n", end);
        printf("first step: %d\n", firstStep);
        printf("last step: %d\n", lastStep);
        printf("total steps: %d\n", totalSteps);
    }

	// Cut the windows up
	totalWindows=0;
	for (i = start; i < end; i += STRIDE) { //from before first step to after last	
		if (i + CUT > end) break; //break if not a full window
		windowIndex[totalWindows] = i;
		windowSteps[totalWindows] = 0;
		floatWindowSteps[totalWindows] = 0.0;
		
		for (j = 0; j < totalSteps; j++) { //iterate through ground truth steps	
			if (GTstepIndex[j] >= i && GTstepIndex[j] < i+CUT) { //keep index between window
				windowSteps[totalWindows]++; //increment number of steps in the window

				//get beginning and end of steps based on step length
				//stepStart = GTstepIndex[j] - SAMPLES_PER_STEP/2;
				//if (stepStart < i) stepStart = i;
				//stepEnd = GTstepIndex[j] + SAMPLES_PER_STEP/2;
				//if (stepEnd >= i+CUT) stepEnd = i + CUT - 1;

				//calculate number of steps in window
				//floatWindowSteps[totalWindows] += ((float)(stepEnd - stepStart + 1) / (float)SAMPLES_PER_STEP);
			}
		}

		//seomthing wrong, over 18 steps in a window
		if (windowSteps[totalWindows] > 18) {
            printf("Error in file: %s\tSteps in window: %d\n", argv[3], windowSteps[totalWindows]);
            exit(0);
        }
		totalWindows++;
	}

    if (DEBUG) printf("totalWindows: %d\n", totalWindows);

	/* print out cut step data */
	if (PRINT) {
		for (i = 0; i < totalWindows; i++) {
			if (DEBUG == 1) {
				printf("%d...%d -> %d\n", windowIndex[i], windowIndex[i]+CUT, windowSteps[i]);
			} else {
                if (windowSteps[i] > -1) {															// only trains on steps above -1, need to remove later
                    if (windowSteps[i] > 18) { 														// error if too many steps in a window
                        printf("Error in file: %s\tSteps in window: %d\tIndex: %d\n", argv[3], windowSteps[i], i);
                        exit(0);
                    }
                    // if (windowSteps[i] == 0 || (k < 0 || k >= totalData)) {
                    //     printf("Zero detected in file: %s\n", argv[3]);
                    // }
                    printf("%d", windowSteps[i]); 													// class is number of steps
                    for (k = windowIndex[i]; k < windowIndex[i] + CUT; k++) {
                        if (k < 0 || k >= totalData) {
                            for (j = 0; j < DATA_FIELDS; j++) printf("\t0.000");		 			// pad with zeros if start or end out of data
                        } else {																	// print data if no need for padding
                            for (j = 0; j < DATA_FIELDS; j++) printf("\t%.3f", Data[j][k]); 
                        }
                    }
                    printf("\n");
                }
			}
		}
	}

	return 0;

}
