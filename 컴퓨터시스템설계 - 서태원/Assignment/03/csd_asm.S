#define csd_LED_ADDR 0x41200000
#define csd_SWITCH_ADDR 0x41210000

.extern csd_main
.global main

main:
 	ldr r0, =csd_LED_ADDR		// r0�� LED�� �ּҸ� �����մϴ�.
	ldr r1, =csd_SWITCH_ADDR	// r1�� ����ġ�� �ּҸ� �����մϴ�.

Delay_loop:
	
	ldr r3, [r1]
	clz r3, r3
	sub r3, r3, #23
 	mov r2, #1
	
LED_loop:
 	str r2, [r0]
 	stmdb sp!, {r0-r3}

	mov r0, r3
 	bl csd_main

	ldr r3, [r1]				// ����ġ �ּҿ��� ����ġ ���� �޾ƿɴϴ�.
	clz r3, r3					// ���� ���� ����ġ ���� ã�� ���� clz�� ����߽��ϴ�.
	sub r3, r3, #23				// ���� ��Ʈ 23���� �׻� 0�̹Ƿ� �� ������ �� �ݴϴ�.
 	mov r2, #1					// ù ��° led�� �����ϱ� ���� r2�� 1���� �ֽ��ϴ�.

LED_loop:						// led�� �����Ű�� �ݺ����Դϴ�.
 	str r2, [r0]				// r2�� ����� ���� led�� �����Ͽ� led�� �����մϴ�.
 	stmdb sp!, {r0-r3}			// �Լ� ȣ�� ���� ���ÿ� r0-r3 ���������� ���� �����մϴ�.

 	b LED_loop
