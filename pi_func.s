	.syntax unified
	.arch armv7-a
	.text
	.align 4
	.arm
	.global pi_func
	.type pi_func, function
pi_func:
temp1 .req d27
temp2 .req d26


    push {r4,r5,lr}

@double one = 1.0;
    one .req d31;
    mov r5,#1
    vmov s0,r5
    vcvt.f64.u32 one,s0

@double zero=0.0;
    zero .req d30;
    mov r5,#0
    vmov s0,r5
    vcvt.f64.u32 zero,s0

@double delta = 1.0 / dt;
    delta .req d29;
    vmov s0,r0
    vcvt.f64.u32 d29,s0    @get dt
    vdiv.f64 delta,one,d29


@d0 to d3    =>   ymm0 = _mm256_set1_pd(1.0);
    mov r5,#1
    vmov s31,r5
    vcvt.f64.u32 d0,s31
    vcvt.f64.u32 d1,s31
    vcvt.f64.u32 d2,s31
    vcvt.f64.u32 d3,s31

@d4 to d7    =>   ymm1 = _mm256_set1_pd(delta);
    vmov d4,delta
    vmov d5,delta
    vmov d6,delta
    vmov d7,delta


@d8 to d11   =>   ymm2 = _mm256_set_pd(delta * 3, delta * 2, delta * 1, 0.0);
@0.0
    vmov d8,zero
@*1
    mov r5,#1
    vmov s0,r5
    vcvt.f64.u32 temp1,s0
    vmul.f64 d9,delta,temp1          @d9=delta*1
@*2
    vadd.f64 d10,d9,d9               @d10=delta*2
@*3
    vadd.f64 d11,d10,d9              @d11=delta*3

@d12 to d15   =>   ymm4 = _mm256_setzero_pd();
    vmov d12,zero
    vmov d13,zero
    vmov d14,zero
    vmov d15,zero

for_loop:
@for (i = dt; i >= 4; i -= 4)//count down loop optimization{


@d16 to d19   =>   ymm3 = _mm256_set1_pd(i * delta);
        vmov s0,r0
        vcvt.f64.u32 d28,s0
        vmov d0,one       @borrow s0(d0=s0+s1),recover s0
        vmul.f64  d28,delta,d28

        vmov d16,d28
        vmov d17,d28
        vmov d18,d28
        vmov d19,d28


@d16 to d19   =>   ymm3 = _mm256_add_pd(ymm3, ymm2);
        vadd.f64 d16,d16,d8
        vadd.f64 d17,d17,d9
        vadd.f64 d18,d18,d10
        vadd.f64 d19,d19,d11

@d16 to d19   =>   ymm3 = _mm256_mul_pd(ymm3, ymm3);
        vmul.f64 d16,d16,d16
        vmul.f64 d17,d17,d17
        vmul.f64 d18,d18,d18
        vmul.f64 d19,d19,d19

@d16 to d19   =>   ymm3 = _mm256_add_pd(ymm0, ymm3);
        vadd.f64 d16,d0,d16
        vadd.f64 d17,d1,d17
        vadd.f64 d18,d2,d18
        vadd.f64 d19,d3,d19

@d16 to d19   =>   ymm3 = _mm256_div_pd(ymm1, ymm3);
        vdiv.f64 d16,d4,d16
        vdiv.f64 d17,d5,d17
        vdiv.f64 d18,d6,d18
        vdiv.f64 d19,d7,d19

@d12 to d15   =>   ymm4 = _mm256_add_pd(ymm4, ymm3);
        vadd.f64 d12,d16,d12
        vadd.f64 d13,d17,d13
        vadd.f64 d14,d18,d14
        vadd.f64 d15,d19,d15

    subs r0,r0,#4
    bhs for_loop
@}

end_loop:
    vadd.f64 d12,d12,d13
    vadd.f64 d14,d14,d15
    vadd.f64 d20,d12,d14

    mov r4,#4
    vmov s0,r4
    vcvt.f64.u32 d21,s0
    vmul.f64 d20,d20,d21    @d20 = (pi/4)*4

    vmov  r0, r1, d20       @return

    pop {r4,r5,pc}
    

    .size pi_func, .-pi_func
    .end

