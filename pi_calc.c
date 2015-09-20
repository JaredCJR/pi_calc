#include <inttypes.h>
#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <time.h>

#if defined(Version_asm)

extern double pi_func(size_t dt);

#endif

#if defined(Version_c)
double pi_func(size_t dt)
{
   double pi = 0.0;
   double delta = 1.0 / dt;
   size_t i;
    for (i = 0; i < dt; i++) {
        double x = (double) i / dt;
        pi += delta / (1.0 + x * x);
    }
    return pi * 4.0;
}
#endif


int main(int argc, char **argv)
{

	double result_pi = 0;
	uint64_t nsec1 = 0;
	uint64_t nsec2 = 0;
	uint64_t time_sum = 0;
	struct timespec t_start, t_end;
	int repeat_time = 1000;
	FILE *file = fopen("./result.txt", "a");


	if (file) {
		
		volatile int i=0;
		for (i = 0;i < repeat_time; i++) {
			nsec1 = 0;
			nsec2 = 0;
			clock_gettime(CLOCK_MONOTONIC, &t_start);
			nsec1 = ((uint64_t)(t_start.tv_sec) * 1000000000LL + t_start.tv_nsec);

            result_pi = pi_func(1280000);

			clock_gettime(CLOCK_MONOTONIC, &t_end);
			nsec2 = (uint64_t)(t_end.tv_sec) * 1000000000LL + t_end.tv_nsec;
			//printf("%" PRIu64 "\n", nsec1);
			//printf("%" PRIu64 "\n", nsec2);
			time_sum += (nsec2 - nsec1);
			printf("%s %d %s %lf\n","No.",i+1,"test, PI = ",result_pi);
		}
		double avg_time = time_sum/repeat_time;
		
		fprintf(file, "%lf\n", avg_time);
		printf("avg_time = %lf\n", avg_time);

		fclose(file);

	} else {
		printf("Open file error!\n");
	}
	return 0;

}

