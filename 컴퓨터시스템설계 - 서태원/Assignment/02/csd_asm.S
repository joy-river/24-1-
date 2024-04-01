

.global main				// 정렬을 진행할 main을 전역으로 설정합니다

main:						// 정렬을 실행하는 main 함수입니다.
     ldr r0, =Input_data	// r0레지스터에 입력 데이터의 주소를 불러옵니다.
     ldr r1, =Output_data	// r1레지스터에 출력 데이터의 주소를 불러옵니다.
     mov r2, #31		    // 정렬을 위한 반복횟수를 31회로 설정합니다.

Selection_sort_out_loop: 	// 선택한 정렬 알고리즘은 선택정렬(Selection sort)로 정했습니다. 따라서 이중 반복문을 사용했습니다.
	 ldr r3, [r0], #4   	// r0 주소의 Input 값을 하나 가져와 r3에 저장하고, r0를 4더한 값으로 업데이트합니다.
	 mov r4, r0			 	// 배열 전체를 순회하고 비교하기 위해 r4에 r0를 복사합니다.
	 mov r5, r2			 	// inner_loop 배열 순회를 반복할 횟수를 r5에 저장합니다.

Selection_sort_inner_loop:
	 ldr r6, [r4], #4		// r3와 비교할 배열의 r4위치의 원소를 r6에 불러옵니다. 그 후 r4를 + 4를 더한 값으로 업데이트합니다.
	 cmp r3, r6				// r3와 r6를 비교하여 CPSR을 업데이트합니다.
	 strgt r3, [r4, #-4]	// 만약 r3가 더 크다면, r6를 가져왔던 메모리 주소[r4, #-4]에 r3를 저장합니다.
	 movgt r3, r6			// 만약 r3가 더 크다면, r6를 r3에 대신 저장합니다.
	 subs r5, r5, #1		// r5에 1을 뺀 값을 r5에 넣고, CPSR을 업데이트합니다.
     bne Selection_sort_inner_loop	// 만약 r5가 0이 아니라면, inner_loop를 반복합니다.

	 str r3, [r1], #4    	// 현재 순회를 반복한 배열에서 가장 작은 값인 r3를 r1 주소에 저장하고, r1을 4더한 값으로 업데이트합니다.
	 subs r2, r2, #1		// r2에 1을 뺀 값을 r2에 넣고, CPSR을 업데이트합니다.
	 bne Selection_sort_out_loop	// 아직 r2가 0이 되지 않았다면, out_loop를 다시 반복합니다.
	 ldr r3, [r0]			// 모든 반복이 끝나고 입력 배열의 마지막 원소, 즉 지금까지 모든 원소 중에서 가장 큰 값을 가지는 원소를 불러옵니다.
	 str r3, [r1]			// 불러온 가장 큰 원소를 Output_data의 마지막 위치에 저장합니다.

forever:					// 정렬이 끝나고 프로그램을 종료시키지 않게 하는 함수입니다.
	nop						// 아무 행동도 하지 않습니다.
	b forever				// forever을 계속 반복하게 만듭니다.

.data
.align 4

Input_data:
 .word 2, 0, -7, -1, 3, 8, -4, 10
 .word -9, -16, 15, 13, 1, 4, -3, 14
 .word -8, -10, -15, 6, -13, -5, 9, 12
 .word -11, -14, -6, 11, 5, 7, -2, -12

Output_data:
 .word 0, 0, 0, 0, 0, 0, 0, 0
 .word 0, 0, 0, 0, 0, 0, 0, 0
 .word 0, 0, 0, 0, 0, 0, 0, 0
 .word 0, 0, 0, 0, 0, 0, 0, 0

