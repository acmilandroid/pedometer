/********************************************************************************
 * This program reads a pedometer data file and window_sizes out windows
 *  of steps. Step indices are determined via steps.txt.
 *
 * The data is window_size from 5 sec prior to first step to 10 sec after
 * last step.  Each window is 5 sec.
 *
 * Usage: ./cutsteps [window_size] [window_window_stride] [pedometer_data_filename.csv] [steps.txt]
 *
 * window_size is the window size in datum (each second is 15 datum)
 * window_stride is the amount of datum to slide the window each time
 * Output is printed to stdout, needs to be piped to a file
 ********************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define	MAX_DATA			54000	//one hour at 15 Hz
#define	MAX_STEPS			10000	//maximum number of steps
#define SMOOTHING			7		//smoothing window
#define	MAX_WINDOWS			30000	//maximum number of windows
#define DATA_FIELDS			3		//number of different sensors being used
#define TOTAL_DATA_FIELDS	17		//total number of columns in csv file to read from
#define DEBUG				0		//debug modes 1 and 2 for alternate prints
#define PRINT				1		//print data
#define SAMPLES_PER_STEP	7		//number of samples used per step
#define MAX_STEPS_5SEC		13		//maximum number of steps in 5 seconds
#define OFFSET_RANGE		66.6	//range in ms that the CSV file times can match


int main(int argc, char *argv[]) {
	FILE	*fpt, *fpt1;
	char	sensor_file[999];
	char	trash[100];
	int		start, end, i, j, k, gt_offset;
	double	total, sensor_start_time, temp_time, time;
	double	**data, **smoothed_data;
	int		total_data_count, total_step_count, total_window_count;
	int		*window_indices, *steps_in_window;
	int		*gt_indices;
	double	*float_steps_in_window;
	int		first_step, last_step;

	//allocate space for everything
	data = (double **)calloc(sizeof(double *), DATA_FIELDS);
	for (i = 0; i < DATA_FIELDS; i++) {
		data[i] = (double *)calloc(sizeof(double), MAX_DATA);
	}
	smoothed_data = (double **)calloc(sizeof(double *), DATA_FIELDS);
	for (i = 0; i < DATA_FIELDS; i++) {
		smoothed_data[i] = (double *)calloc(sizeof(double), MAX_DATA);
	}
	window_indices = (int *)calloc(sizeof(int), MAX_WINDOWS);
	steps_in_window = (int *)calloc(sizeof(int), MAX_WINDOWS);
	float_steps_in_window = (double *)calloc(sizeof(int), MAX_WINDOWS);

	if (argc != 5) {
		printf("Usage: ./cutsteps [window_size] [window_window_stride] [pedometer_data_filename.csv] [steps.txt]\n");
		exit(0);
	}

	if ((fpt=fopen(argv[3], "rb")) == NULL) {
		printf("Unable to open %s for reading\n", argv[3]);
		exit(0);
	}

	sensor_start_time = -1;
	strcpy(sensor_file, argv[3]);
	// find first time index
	for (i = 1; i <= 3; i++) {
		sensor_file[strlen(sensor_file)-5] = (char)(i+48);
		if ((fpt1=fopen(sensor_file, "rb")) == NULL) {
			printf("Unable to open %s for reading\n", sensor_file);
			exit(0);
		}
		//scan and throw away header information
		for (j = 0; j < 2*TOTAL_DATA_FIELDS + 7; j++) {
			fscanf(fpt1, "%s", trash);
		}
		// read sensor's start time
		fscanf(fpt1, "%lf", &temp_time);
		if (temp_time > sensor_start_time) {
			sensor_start_time = temp_time;
		}
		fclose(fpt1);
	}
	gt_offset = 0;

	int window_size = atoi(argv[1]);
	int window_stride = atoi(argv[2]);

	// read data file, determine total amount of data
	total_data_count = 0;

	//scan and throw away header information
	for (i = 0; i < 2*TOTAL_DATA_FIELDS + 6; i++) {
		fscanf(fpt, "%s", trash);
	}

	//scan acceleration data
	while (
		fscanf(fpt,"%s %lf %s %s %s %s %s %s %s %s %lf %lf %lf %s %s %s %s",
			trash, //timestamp
			&time, //realtime
			trash, //GSR
			trash, //QuatW
			trash, //QuatX
			trash, //QuatY
			trash, //QuatZ
			trash, //GyroX
			trash, //GyroY
			trash, //GyroZ
			&(data[0][total_data_count]), //AccelX
			&(data[1][total_data_count]), //AccelY
			&(data[2][total_data_count]), //AccelZ
			trash, //MagX
			trash, //MagY
			trash, //MagZ
			trash) //DateTime
		== TOTAL_DATA_FIELDS)
	{
		total_data_count++;
		// if the read time is within range, the offset is the current sensor reading
		// note: sometimes this will occur twice bc the time is not perfect
		// this is okay, this method matches Ryan's Stepcounter VIEW implementation
		if (time > sensor_start_time-OFFSET_RANGE && time < sensor_start_time+OFFSET_RANGE) {
			gt_offset = total_data_count-1;
		}
	}

	fclose(fpt);

	/* convert data voltages to deg/sec (gyros)
	** and gravities (accelerometers)
	** gyro=LPY410al, 2.5mv per deg/sec, zero-point found
	** by calculating the average data value of the whole recording
	** accel=LIS344alh, Vdd=3.3v, 5/3.3=1.515 gravities per volt */
	// for (i = 0; i < total_data_count; i++) {
	//         /* 3.3v supply so 1/2(3.3)=1.65 reference */
	//         /* 15/3.3=4.5454 instead, if chip wired to +-6g */
	//     for (j = 0; j < 3; j++) {
	//         data[i][j]=(data[i][j]-1.65)*(5.0/3.3);
	//     }
	//     /* reference voltage calculated as average ADC value for while file */
	//     for (j = 3; j < 6; j++) {
	//         data[i][j]=(data[i][j]-zero[j-3])*400.0;
	//     }
	// }

	// fill beginning and end without smoothing
	for (i = 0; i < SMOOTHING; i++) {
		for (j = 0; j < DATA_FIELDS; j++) {
			smoothed_data[j][i] = data[j][i];
		}
	}
	for (i = total_data_count - SMOOTHING; i < total_data_count; i++) {
		for (j = 0; j < DATA_FIELDS; j++) {
			smoothed_data[j][i] = data[j][i];
		}
	}

	// smooth data
	for (i = SMOOTHING; i < total_data_count - SMOOTHING; i++) {
		/* averaging over a 1-sec window (15 samples) centered on the datum */
		for (j = 0; j < DATA_FIELDS; j++) {
			total = 0.0;
			for (k = i - SMOOTHING; k <= i + SMOOTHING; k++) {
				if (k >= 0  &&  k < total_data_count) total += data[j][k];
			}
			smoothed_data[j][i] = total / (SMOOTHING*2 + 1);
		}
	}

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
	gt_indices = malloc(sizeof(int) * MAX_STEPS);

	// read step ground truth file
	total_step_count = 0;
	first_step = MAX_DATA;
	last_step = -1;
	while (fscanf(fpt, "%d %s", &(gt_indices[total_step_count]), foot[total_step_count]) == 2) {
		//if (strlen(foot[total_step_count]) != 1) break; //excludes ledge and redge shifts
		//find min and max step index
		if (first_step > gt_indices[total_step_count]) first_step = gt_indices[total_step_count];
		if (last_step < gt_indices[total_step_count]) last_step = gt_indices[total_step_count];
		total_step_count++;
	}
	fclose(fpt);

	// cut windows [window_size] datum prior to first step, to [window_size+window_stride] datum after last step
	// must account for the ground truth index offset
	start = first_step - window_size + gt_offset;
	end = last_step + window_size + window_stride + gt_offset;

	if (DEBUG) {
		printf("start: %d\n", start);
		printf("end: %d\n", end);
		printf("first step: %d\n", first_step);
		printf("last step: %d\n", last_step);
		printf("total steps: %d\n", total_step_count);
	}

	// cut the windows up
	total_window_count=0;
	for (i = start; i + window_size <= end; i += window_stride) { //from before first step to after last

		window_indices[total_window_count] = i;
		steps_in_window[total_window_count] = 0;
		float_steps_in_window[total_window_count] = 0.0;

		// find number of steps in the window
		for (j = 0; j < total_step_count; j++) { //iterate through ground truth steps
			if (gt_indices[j] >= i-gt_offset && gt_indices[j] < i+window_size-gt_offset) { //keep index between window, adjusted for offset
				steps_in_window[total_window_count]++; //increment number of steps in the window

				//get beginning and end of steps based on step length
				//stepStart = gt_indices[j] - SAMPLES_PER_STEP/2;
				//if (stepStart < i) stepStart = i;
				//stepEnd = gt_indices[j] + SAMPLES_PER_STEP/2;
				//if (stepEnd >= i+window_size) stepEnd = i + window_size - 1;

				//calculate number of steps in window
				//float_steps_in_window[total_window_count] += ((double)(stepEnd - stepStart + 1) / (double)SAMPLES_PER_STEP);
			}
		}

		total_window_count++;
	}

	if (DEBUG) printf("total_window_count: %d\n", total_window_count);

	/* print out window_size step data */
	if (PRINT) {
		for (i = 0; i < total_window_count; i++) {
			if (DEBUG == 1) {
				printf("%d...%d -> %d\n", window_indices[i], window_indices[i]+window_size, steps_in_window[i]);
			} else {
				if (steps_in_window[i] > -1) {														         // only trains on steps above -1, need to remove later
					if (steps_in_window[i] > MAX_STEPS_5SEC*window_size/75) {                                        // caps maximum steps in a window at MAX_STEPS_5SEC
						steps_in_window[i] = MAX_STEPS_5SEC*window_size/75;
					}
					// if (steps_in_window[i] == 0 || (k < 0 || k >= total_data_count)) {
					//     printf("Zero detected in file: %s\n", argv[3]);
					// }
					printf("%d", steps_in_window[i]); 													// class is number of steps
					for (k = window_indices[i]; k < window_indices[i] + window_size; k++) {
						if (k < 0 || k >= total_data_count) {
							for (j = 0; j < DATA_FIELDS; j++) printf("\t0.000");		 			// pad with zeros if start or end out of data
						} else {																	// print data if no need for padding
							for (j = 0; j < DATA_FIELDS; j++) printf("\t%.3f", smoothed_data[j][k-1]);
						}
					}
					printf("\n");
				}
			}
		}
	}

	return 0;

}
