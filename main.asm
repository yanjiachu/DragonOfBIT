.386
.model flat, STDCALL

INCLUDE	GraphWin.inc
INCLUDE gdi32.inc
INCLUDE msimg32.inc
INCLUDELIB gdi32.lib
INCLUDELIB msimg32.lib
INCLUDELIB irvine32.lib
INCLUDELIB kernel32.lib
INCLUDELIB user32.lib
INCLUDE bhw.inc
INCLUDELIB msvcrt.lib


printf	PROTO	C :ptr sbyte,:VARARG
WriteDec PROTO
Crlf PROTO
Startup PROTO
ProcessMouseClick PROTO :DWORD, :DWORD
Drawline2 PROTO:DWORD, :DWORD, :DWORD,:DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
UpInMenu PROTO
DownInMenu PROTO
EnterInMenu PROTO
EscapeInMenu PROTO
GetMyRect PROTO :DWORD ;

.data

szMsg	BYTE "%d",0ah,0
WindowName BYTE "�����Ķ���", 0
className BYTE "BIT", 0

;���ô������ڵ�ģ��
;����һ������
MainWin WNDCLASS <NULL, WinProc, NULL, NULL, NULL, NULL, NULL, COLOR_WINDOW, NULL, className>

msg MSGStruct <>	;��Ϣ�ṹ���û���Ż�ȡ��message
winRect RECT <>
hMainWnd DWORD ?	;�����ڵľ��
hInstance DWORD ?

hbitmap DWORD ?		;ͼƬ�ľ��
hdcMem DWORD ?		;hdc�����ʹ��Ƶ�ʸ�
hdcPic DWORD ?		;hdc���������ʹ��
hdc DWORD ?
holdbr DWORD ?
holdft DWORD ?
hdcStart DWORD ?
ps PAINTSTRUCT <>

BreakWallType DWORD 0
BreakWallPos DWORD 0
DirectionMapToW DWORD 4, 2, 3, 1
BulletMove DWORD 7, 0, -7, 0, 0, 7, 0, -7
EnemyMove DWORD 3, 0, -3, 0, 0, 3, 0, -3, 3, 0, -3, 0, 0, 3, 0, -3, 5, 0, -5, 0, 0, 5, 0, -5
BulletPosFix DWORD 10, 0, -10, 0, 0, 10, 0, -10
DrawHalfSpiritMask DWORD 32, 32, 16, 16, 16, 16, 32, 32, 0, 0, 0, 16, 0, 16, 0, 0
ScoreText BYTE "000000", 0
RandomPlace DWORD 64, 224, 384

WaterSpirit DWORD ?				; ˮ��ͼƬ
WhichMenu DWORD 0				; ����ѡ�0 ��ʼ��1 ѡ����Ϸģʽ��2 ������Ϸ��3 ��Ϸ����
ButtonNumber DWORD 2, 5, 0, 2	; ���������µ�ѡ�����
SelectMenu DWORD 0				; ����ѡ��Ĳ˵���
GameMode DWORD 0				; ��Ϸģʽ 0Ϊ����ģʽ��1Ϊ��սģʽ
IsDoublePlayer DWORD 0			; ��Ϸģʽ��00�ǵ�����Ϸ��11��˫����Ϸ

;���̲��������±�Ϊ1
UpKeyHold DWORD 0
DownKeyHold DWORD 0
LeftKeyHold DWORD 0
RightKeyHold DWORD 0
WKeyHold DWORD 0
SKeyHold DWORD 0
AKeyHold DWORD 0
DKeyHold DWORD 0
SpaceKeyHold DWORD 0
EnterKeyHold DWORD 0


;��������λ
ButtonSizeX	DWORD	128
ButtonSizeY	DWORD	32

rect1Left DWORD 256
rect1Top DWORD 160

rect2Left DWORD 256
rect2Top DWORD 192

rect3Left DWORD 256
rect3Top DWORD 224

rect4Left DWORD 256
rect4Top DWORD 256

rect5Left DWORD 256
rect5Top DWORD 288

;������
waitStart DWORD 1Fh		;����ǰ������
isStart DWORD 1			;��������Ҫ������
bkColor DWORD 0ffffffh	;����ʱ����ɫ


; Map�����˵�ǰ��Ϸ�׶εĵ�ͼ��������Ϸ�ؿ��仯�����ϱ仯
;0��ʾ�գ�1�Ǻ��棬3��ǽ�壬11�Ǻ�ǽ�壬8�ǻ���
Map			DWORD 225 DUP(?)

;YourRole��һ�ж�Ӧһ����ң�һ�ж�Ӧһ������
;����(0=������,1=���,2=δʹ��,3=��ͨ,4=ǿ��,5=����)
;X
;Y
;����
;�ӵ�����(0=������,1=����,2~9=��ը)
;�ӵ�X
;�ӵ�Y
;�ӵ�����
YourRole	DWORD 0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0
			
;Enemy��������10��������ͬʱ�ܳ��ֵĹ�������
Enemy		DWORD 0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0
YourLife	DWORD 0,0
EnemyLife	DWORD 0,0,0
Score		DWORD 0,0
Round		DWORD 0	;Round�����������ĸ���ͼ��0��Ӧ�޾�ģʽ��12345��Ӧ��սģʽ��5���ؿ�
WaitingTime	DWORD -1
YouDie		DWORD 0	;0�����1��������

;RoundMap�����Ԥ���ĵ�ͼ
			;�޾��ؿ�
RoundMap	DWORD  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DWORD  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
			DWORD  3,11,11,11,11,11,11,11,11,11,11,11,11,11, 3
			DWORD  3, 1, 1, 1, 1, 3, 3, 1, 3, 1, 1, 1, 1, 1, 3
			DWORD  3, 1, 3, 3, 3, 1, 3, 1, 3, 3, 3, 1, 3, 3, 3
			DWORD  3, 1, 3, 3, 3, 1, 3, 1, 3, 3, 3, 1, 3, 3, 3
			DWORD  3, 1, 1, 1, 1, 3, 3, 1, 3, 3, 3, 1, 3, 3, 3
			DWORD  3, 1, 3, 3, 3, 1, 3, 1, 3, 3, 3, 1, 3, 3, 3
			DWORD  3, 1, 3, 3, 3, 1, 3, 1, 3, 3, 3, 1, 3, 3, 3
			DWORD  3, 1, 1, 1, 1, 3, 3, 1, 3, 3, 3, 1, 3, 3, 3
			DWORD  3,11,11,11,11,11,11,11,11,11,11,11,11,11, 3
			DWORD  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
			DWORD  3, 3, 3, 3, 3, 3, 3,11, 3, 3, 3, 3, 3, 3, 3
			DWORD  3,11,11,11, 3, 3,11,11,11, 3, 3,11,11,11, 3
			DWORD  0, 0, 0, 0, 0,11,11, 8,11,11, 0, 0, 0, 0, 0
			;�ؿ�1                                  
			DWORD  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 0, 3, 3, 0, 0, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 3, 0, 3, 0, 0, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 3,11,11,11, 3, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 3,11, 8,11, 3, 0, 0, 0, 0, 0
			;�ؿ�2
			DWORD  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DWORD  1, 1, 0, 0, 0,11,11,11,11,11, 0, 0, 0, 1, 1
			DWORD  1, 1, 0, 0, 0, 0, 0, 0, 0,11, 0, 0, 0, 1, 1
			DWORD  1, 1, 0, 0, 0,11,11,11,11,11, 0, 0, 0, 1, 1
			DWORD  1, 1, 0, 0, 0,11, 0, 0, 0, 0, 0, 0, 0, 1, 1
			DWORD  1, 1, 0, 0, 0,11,11,11,11,11, 0, 0, 0, 1, 1
			DWORD  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DWORD  3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3
			DWORD  3, 3, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 3, 3
			DWORD  3, 0, 0, 0, 0, 0, 3, 3, 3, 0, 0, 0, 0, 0, 3
			DWORD  0, 0, 0, 0, 0, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 3,11,11,11, 3, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 3,11, 8,11, 3, 0, 0, 0, 0, 0
			;�ؿ�3
			DWORD  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DWORD  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
			DWORD  0, 0, 0, 0, 0, 0,11,11,11, 0, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0,11, 0, 0, 0,11, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 0, 0, 0,11, 0, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 0,11,11,11, 0, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 0, 0, 0,11, 0, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0,11, 0, 0, 0,11, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 0,11,11,11, 0, 0, 0, 0, 0, 0
			DWORD  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
			DWORD  0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0
			DWORD  3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3
			DWORD  3, 3, 3, 0, 0, 0, 3,11, 3, 0, 0, 0, 3, 3, 3
			DWORD  3, 3, 3, 0, 0, 0,11, 8,11, 0, 0, 0, 3, 3, 3
			;�ؿ�4
			DWORD  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 1, 0, 0, 0,11, 0, 1, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 1, 0, 0,11,11, 0, 1, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 1, 0,11, 0,11, 0, 1, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 1,11, 0, 0,11, 0, 1, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 1,11,11,11,11,11, 1, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 1, 0, 0, 0,11, 0, 1, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 1, 0, 0, 0,11, 0, 1, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DWORD  0, 0,11, 0, 0, 0, 0, 0, 0, 0, 0, 0,11, 0, 0
			DWORD  0,11,11,11, 0, 0, 0,11, 0, 0, 0,11,11,11, 0
			DWORD  0, 0, 0, 0, 0, 0,11, 8,11, 0, 0, 0, 0, 0, 0
			;�ؿ�5
			DWORD  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DWORD  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
			DWORD  0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 1, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0
			DWORD  0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0
			DWORD  0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0
			DWORD  0, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 0
			DWORD  0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0
			DWORD  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0
			DWORD  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
			DWORD  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 0, 0,11, 0, 0, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 0,11,11,11, 0, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0,11,11, 8,11,11, 0, 0, 0, 0, 0

;RoundEnemy������Ϊһ�ڣ��涨��ĳ���ؿ������ֵֹ�����
RoundEnemy	DWORD 9999,9999,9999,3,0,0,5,1,0,7,2,0,8,5,0,0,0,10
RoundSpeed	DWORD 1,60,60,60,50,50,1


.code

WinMain proc
    invoke Randomize

    invoke GetModuleHandle, NULL
    mov hInstance, eax

    invoke LoadIcon, hInstance, 999
    mov MainWin.hIcon, eax

    invoke LoadCursor, NULL, IDC_ARROW
    mov MainWin.hCursor, eax

    invoke RegisterClass, ADDR MainWin
    cmp eax, 0
    je ExitProgram

    invoke CreateWindowEx, 0, ADDR className, ADDR WindowName,  (WS_BORDER+WS_CAPTION+WS_SYSMENU), CW_USEDEFAULT, CW_USEDEFAULT, 650, 510, NULL, NULL, hInstance, NULL
    cmp eax, 0
    je ExitProgram
    mov hMainWnd, eax

    invoke ShowWindow, hMainWnd, SW_SHOW
    invoke UpdateWindow, hMainWnd

MessageLoop:
    invoke GetMessage, ADDR msg, NULL, 0, 0
    cmp eax, 0
    je ExitProgram

    invoke TranslateMessage, ADDR msg
    invoke DispatchMessage, ADDR msg
    jmp MessageLoop

ExitProgram:
    invoke ExitProcess, 0

WinMain endp

;�ص�������������Ӧ�����ϲ�����һ���¼���������꣬���̵�
WinProc proc
	push ebp		;�������߱���Ĵ���
	mov ebp,esp		;ջ��ָ��%esp
	;��һ����֧�ṹ�����ݻ����¼�����ת����ͬ��֧
	mov eax,[ebp+12]	;ȡmessage����
	;������
	.IF eax == WM_LBUTTONDOWN
		;��ȡ�������
		mov     eax, [ebp+20]
		movzx   ebx, ax
		shr     eax, 16
		invoke ProcessMouseClick, ebx, eax
	.ENDIF

	.IF eax == WM_KEYDOWN
		; ���¼��̣�����Ӧ�� Hold ������ 1���ҽ��ж�Ӧ����
		jmp KeyDownMessage
	.ELSEIF eax == WM_KEYUP
		; �ɿ����̣�����Ӧ�� Hold ������ 0
		jmp KeyUpMessage
	.ELSEIF eax == WM_CREATE
		; �ڳ�������֮������ʼ������
		jmp CreateWindowMessage
	.ELSEIF eax == WM_CLOSE
		; ����������Ͻǡ��ţ��رմ��ڣ��˳�����ͬʱ���ٺ�̨�ļ�ʱ��
		jmp CloseWindowMessage
	.ELSEIF eax == WM_PAINT
		; �κζԴ��ڵĸ��ģ��������һ�� WM_PAINT ��Ϣ��������ʱ��Ҳ�ᴥ�� WM_PAINT��
		jmp PaintMessage
	.ELSEIF eax == WM_TIMER
		; ��ʱ���¼���ÿ��һ��ʱ�����»��ƴ��ڣ������� PaintMessage ������֣�
		jmp TimerMessage
	.ELSE
		; ����Ĭ�ϻص���������
		jmp OtherMessage
	.ENDIF

	
		;�ڶ�����֧��ͨ���жϾ����¼�����ת����ͬ��֧
		;������ѹ
	KeyDownMessage:
		mov eax,[ebp+16]
		cmp eax,38
		jne nup1
		invoke UpInMenu;��
		mov UpKeyHold,1
	nup1:
		cmp eax,40
		jne ndown1
		invoke DownInMenu;��
		mov DownKeyHold,1
	ndown1:
		cmp eax,37
		jne nleft1
		mov LeftKeyHold,1;��
	nleft1:
		cmp eax,39
		jne nright1
		mov RightKeyHold,1;��
	nright1:
		cmp eax,32
		jne nspace1
		mov SpaceKeyHold,1
		invoke EnterInMenu;�ո�
	nspace1:
		cmp eax,13
		jne nenter1
		mov EnterKeyHold,1
		invoke EnterInMenu;�س�
	nenter1:
		cmp eax,27
		jne nescape1
		invoke EscapeInMenu;esc
	nescape1:
		cmp eax,65
		jne na1
		mov AKeyHold,1;A
	na1:
		cmp eax,68
		jne nd1
		mov DKeyHold,1;D
	nd1:
		cmp eax,83
		jne ns1
		mov SKeyHold,1;S
	ns1:
		cmp eax,87
		jne nw1
		mov WKeyHold,1;W
	nw1:
		jmp WinProcExit;����Ҫ����ļ�
		
		;�����ͷ�
		;�ṹͬ������ѹ
	KeyUpMessage:
		mov eax,[ebp+16]

		cmp eax,38
		jne nup2
		mov UpKeyHold,0
	nup2:
		cmp eax,40
		jne ndown2
		mov DownKeyHold,0
	ndown2:
		cmp eax,37
		jne nleft2
		mov LeftKeyHold,0
	nleft2:
		cmp eax,39
		jne nright2
		mov RightKeyHold,0
	nright2:
		cmp eax,32
		jne nspace2
		mov SpaceKeyHold,0
	nspace2:
		cmp eax,13
		jne nenter2
		mov EnterKeyHold,0
	nenter2:
		cmp eax,65
		jne na2
		mov AKeyHold,0
	na2:
		cmp eax,68
		jne nd2
		mov DKeyHold,0
	nd2:
		cmp eax,83
		jne ns2
		mov SKeyHold,0
	ns2:
		cmp eax,87
		jne nw2
		mov WKeyHold,0
	nw2:
		jmp WinProcExit


	CreateWindowMessage:
		mov eax, [ebp+8]
		mov hMainWnd, eax

		; Ϊ��ǰ���ڼ�һ����ʱ������ʱ���᲻�Ϸ�����ʱ���¼�
		invoke SetTimer, hMainWnd, 1, 30, NULL

		; ��ȡ���������ľ��
		invoke GetDC, hMainWnd
		mov hdc, eax  ; ���ص�ǰ���ڹ�����DC���

		; �����￪ʼ�����¶���
		invoke CreateCompatibleDC, hdc  ; �������ݻ�������һ����ָ���豸���ݵ��ڴ��豸�����Ļ�����DC��
		mov hdcStart, eax

		invoke LoadImageA, hInstance, 1002, 0,0,0,0
		mov hbitmap, eax  ; ������Դͼ���

		invoke SelectObject, hdcStart, hbitmap  ; ��λͼ�ŵ�DC��

		invoke CreateCompatibleDC, hdc  ; �������ݻ�������һ����ָ���豸���ݵ��ڴ��豸�����Ļ�����DC��
		mov hdcPic, eax  ; ���ݵ��ڴ�DC������൱�����ɸ�������

		invoke CreateCompatibleDC, hdc  ; �������ݻ�������һ����ָ���豸���ݵ��ڴ��豸�����Ļ�����DC��
		mov hdcPic, eax  ; ���ݵ��ڴ�DC������൱�����ɸ�������

		invoke LoadImageA, hInstance, 1001, 0,0,0,0
		mov hbitmap, eax

		invoke SelectObject, hdcPic, hbitmap

		invoke CreateCompatibleDC, hdc
		mov hdcMem, eax

		invoke CreateCompatibleBitmap, hdc, 640,480
		mov hbitmap, eax  ; ���ش���õ�λͼ�ľ��

		invoke SelectObject, hdcMem, hbitmap

		invoke SetTextColor, hdcMem, 0FFFFFFh  ; �����µ�ͼ���ı���ɫ

		invoke SetBkColor, hdcMem, 0  ; ���ñ�����ɫ ��ɫ

		invoke ReleaseDC, hMainWnd, hdc

		jmp WinProcExit


	; �رմ���
	CloseWindowMessage:
		; invoke printf, offset szMsg, 2
		invoke PostQuitMessage, 0
		invoke KillTimer, hMainWnd, 1
		jmp WinProcExit

	PaintMessage:
		; invoke printf, offset szMsg, 1
		invoke BeginPaint, hMainWnd, offset ps
		mov hdc, eax

		invoke CreateSolidBrush, bkColor

		; push 0; BLACK_BRUSH
		; call GetStockObject

		invoke SelectObject, hdcMem, eax
		mov holdbr, eax

		invoke GetStockObject, SYSTEM_FIXED_FONT
		invoke SelectObject, hdcMem, eax
		mov holdft, eax

		invoke Rectangle, hdcMem, 0, 0, 640,480

		; ������������
		.IF isStart == 0
			call DrawUI
		.ELSE
			invoke Startup
		.ENDIF

		invoke SelectObject, hdcMem, holdbr
		invoke SelectObject, hdcMem, holdft

		invoke BitBlt, hdc, 0, 0,640,480, hdcMem, 0, 0, SRCCOPY

		invoke EndPaint, hMainWnd, offset ps
		jmp WinProcExit

		;��ʱ���¼�
	TimerMessage:
		call TimerTick

		invoke RedrawWindow, hMainWnd, NULL, NULL, 1

		jmp WinProcExit

	; Ĭ�ϻص�����
	OtherMessage:    
		invoke DefWindowProc, [ebp+8], [ebp+12], [ebp+16], [ebp+20]

	WinProcExit:
		mov esp, ebp
		pop ebp
		ret 16
Winproc endp

;������
ProcessMouseClick proc mouseX:DWORD, mouseY:DWORD
	.IF	WhichMenu == 0
	;��ʼ��Ϸ
		mov eax, mouseX
		cmp eax, rect1Left
		jl NotInRect1
		mov eax, mouseX
		mov ecx, rect1Left
		add ecx, ButtonSizeX
		cmp eax, ecx
		jg NotInRect1
		mov eax, mouseY
		cmp eax, rect1Top
		jl NotInRect1
		mov eax, mouseY
		mov ecx, rect1Top
		add ecx, ButtonSizeY
		cmp eax, ecx
		jg NotInRect1
		mov WhichMenu, 1
		jmp DoneClick

	NotInRect1:
	; ������Ϸ
	    mov eax, mouseX
		cmp eax, rect2Left
		jl NotInRect2
		mov eax, mouseX
		mov ecx, rect2Left
		add ecx, ButtonSizeX
		cmp eax, ecx
		jg NotInRect2
		mov eax, mouseY
		cmp eax, rect2Top
		jl NotInRect2
		mov eax, mouseY
		mov ecx, rect2Top
		add ecx, ButtonSizeY
		cmp eax, ecx
		jg NotInRect2
		jmp EnterToEndGame
	NotInRect2:
	
	.ELSEIF WhichMenu == 1
	;����ѡ��ͬģʽ
		mov eax, mouseX
		cmp eax, rect1Left
		jl NotInRect21
		mov eax, mouseX
		mov ecx, rect1Left
		add ecx, ButtonSizeX
		cmp eax, ecx
		jg NotInRect21
		mov eax, mouseY
		cmp eax, rect1Top
		jl NotInRect21
		mov eax, mouseY
		mov ecx, rect1Top
		add ecx, ButtonSizeY
		cmp eax, ecx
		jg NotInRect21
		mov WhichMenu, 2
		mov GameMode, 0
		mov IsDoublePlayer, 0
		jmp Runmygame
	NotInRect21:
	
		mov eax, mouseX
		cmp eax, rect2Left
		jl NotInRect22
		mov eax, mouseX
		mov ecx, rect2Left
		add ecx, ButtonSizeX
		cmp eax, ecx
		jg NotInRect22
		mov eax, mouseY
		cmp eax, rect2Top
		jl NotInRect22
		mov eax, mouseY
		mov ecx, rect2Top
		add ecx, ButtonSizeY
		cmp eax, ecx
		jg NotInRect22
		mov WhichMenu, 2
		mov GameMode, 1
		mov IsDoublePlayer, 0
		jmp Runmygame
	NotInRect22:
	
		mov eax, mouseX
		cmp eax, rect3Left
		jl NotInRect23
		mov eax, mouseX
		mov ecx, rect3Left
		add ecx, ButtonSizeX
		cmp eax, ecx
		jg NotInRect23
		mov eax, mouseY
		cmp eax, rect3Top
		jl NotInRect23
		mov eax, mouseY
		mov ecx, rect3Top
		add ecx, ButtonSizeY
		cmp eax, ecx
		jg NotInRect23
		mov WhichMenu, 2
		mov GameMode, 0
		mov IsDoublePlayer, 1
		jmp Runmygame
	NotInRect23:
	
		mov eax, mouseX
		cmp eax, rect3Left
		jl NotInRect24
		mov eax, mouseX
		mov ecx, rect4Left
		add ecx, ButtonSizeX
		cmp eax, ecx
		jg NotInRect24
		mov eax, mouseY
		cmp eax, rect4Top
		jl NotInRect24
		mov eax, mouseY
		mov ecx, rect4Top
		add ecx, ButtonSizeY
		cmp eax, ecx
		jg NotInRect24
		mov WhichMenu, 2
		mov GameMode, 1
		mov IsDoublePlayer, 1
		jmp Runmygame
	NotInRect24:
	
		mov eax, mouseX
		cmp eax, rect3Left
		jl NotInRect25
		mov eax, mouseX
		mov ecx, rect5Left
		add ecx, ButtonSizeX
		cmp eax, ecx
		jg NotInRect25
		mov eax, mouseY
		cmp eax, rect5Top
		jl NotInRect25
		mov eax, mouseY
		mov ecx, rect5Top
		add ecx, ButtonSizeY
		cmp eax, ecx
		jg NotInRect25
		mov WhichMenu, 0
	NotInRect25:
		jmp DoneClick

	.ELSEIF	WhichMenu == 3
	;��ʼ��Ϸ
		mov eax, mouseX
		cmp eax, rect1Left
		jl NotInRect31
		mov eax, mouseX
		mov ecx, rect1Left
		add ecx, ButtonSizeX
		cmp eax, ecx
		jg NotInRect31
		mov eax, mouseY
		cmp eax, rect1Top
		jl NotInRect31
		mov eax, mouseY
		mov ecx, rect1Top
		add ecx, ButtonSizeY
		cmp eax, ecx
		jg NotInRect31
		mov WhichMenu, 1
		jmp DoneClick

	NotInRect31:
    ; ������Ϸ
	    mov eax, mouseX
		cmp eax, rect2Left
		jl NotInRect32
		mov eax, mouseX
		mov ecx, rect2Left
		add ecx, ButtonSizeX
		cmp eax, ecx
		jg NotInRect32
		mov eax, mouseY
		cmp eax, rect2Top
		jl NotInRect32
		mov eax, mouseY
		mov ecx, rect2Top
		add ecx, ButtonSizeY
		cmp eax, ecx
		jg NotInRect32
		jmp EnterToEndGame
	NotInRect32:

	Runmygame:
		call ResetField
	
		jmp DoneClick
	
	.ENDIF

DoneClick:
    ret
ProcessMouseClick endp

DrawUI:
		;��һ����֧������WhichMenu�����жϵ�ǰ�������棬ת����Ӧ�Ļ��Ʒ�֧
    .IF WhichMenu == 0
        jmp DrawMain
    .ELSEIF WhichMenu == 1
        jmp DrawMode
    .ELSEIF WhichMenu == 2
        jmp DrawGame
    .ELSEIF WhichMenu == 3
        jmp DrawResult
    .ELSE
        jmp DrawUIReturn
    .ENDIF

	;���������
	DrawMain:
		invoke Drawline2, 20, 0, 0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 32, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 64, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 96, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 128, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 160, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 192, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 224, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 256, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,0,0,0
		invoke Drawline2, 20, 0, 288, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 320, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 352, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 384, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 416, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 448, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


		invoke Drawline2, 20, 0, 0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 32, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 64, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 96, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 128, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 160, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2
		invoke Drawline2, 20, 0, 192, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,4,5,4,5
		invoke Drawline2, 20, 0, 224, 0,0,0,0,0,0,0,0,0,0,48,0,0,2,3,4,5,6,5,4
		invoke Drawline2, 20, 0, 256, 0,0,0,0,0,0d00h,0,0,0d00h,0,0,0,2,3,4,5,40,5,4,3
		invoke Drawline2, 20, 0, 288, 0,0,0,0d00h,0d00h,0,0,48,0,0,0d00h,0,0,2,3,4,5,6,5,4
		invoke Drawline2, 20, 0, 320, 0,0c00h,0,0,0d00h,0,0d00h,0,0,0,48,0,0,0,2,2,2,2,2,2
		invoke Drawline2, 20, 0, 352, 0,0d00h,0,18,0,0,0d00h,0,0,48,0,0,0,0,0,0,0d00h,0,0,0
		invoke Drawline2, 20, 0, 384, 0,0,0e00h,0,0,0,0,0,0d00h,0,0d00h,0,0,0d00h,0,0d00h,0,0,0d00h,0
		invoke Drawline2, 20, 0, 416, 0,0d00h,0,0,0,0d00h,0,0,0d00h,0,0,0,0,0,48,0,0,0,0,0
		invoke Drawline2, 20, 0, 448, 0,0,0,0,0d00h,0,0,0,0,0,0d00h,0,0,0,0,0,0d00h,0,0,0d00h
	
		;invoke Drawline2, 20, 0, 0, 110000b,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		
		invoke TransparentBlt, hdcMem, 128, 48, 384, 64, hdcPic, 256, 192, 192, 32, 08000H


		;���Ƶ�һ��
		push 0Fh
		push 0Eh
		push 0Dh
		push 0Ch
		push rect1Top
		push rect1Left
		push 4
		call DrawLine
		;���Ƶڶ���
		push 0Bh
		push 09h
		push 36H
		push 2Eh
		push rect2Top
		push rect1Left
		push 4
		call DrawLine
		jmp DrawMenuSelect
		
		;ѡ��������
	DrawMode:
		invoke Drawline2, 20, 0, 0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 32, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 64, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 96, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 128, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 160, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 192, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 224, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 256, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,0,0,0
		invoke Drawline2, 20, 0, 288, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 320, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 352, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 384, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 416, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 448, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		

		invoke Drawline2, 20, 0, 0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 32, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 64, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 96, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 128, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 160, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2
		invoke Drawline2, 20, 0, 192, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,4,5,4,5
		invoke Drawline2, 20, 0, 224, 0,0,0,0,0,0,0,0,0,0,0,0,0,2,3,4,5,6,5,4
		invoke Drawline2, 20, 0, 256, 0,0,0,0,0,0d00h,0,0,0,0,0,0,2,3,4,5,40,5,4,3
		invoke Drawline2, 20, 0, 288, 0,0,0,0d00h,0d00h,0,0,0,0,0,0,0,0,2,3,4,5,6,5,4
		invoke Drawline2, 20, 0, 320, 0,0c00h,0,0,0d00h,0,0d00h,0,0,0,48,0,0,0,2,2,2,2,2,2
		invoke Drawline2, 20, 0, 352, 0,0d00h,0,18,0,0,0d00h,0,0,48,0,0,0,0,0,0,0d00h,0,0,0
		invoke Drawline2, 20, 0, 384, 0,0,0e00h,0,0,0,0,0,0d00h,0,0d00h,0,0,0d00h,0,0d00h,0,0,0d00h,0
		invoke Drawline2, 20, 0, 416, 0,0d00h,0,0,0,0d00h,0,0,0d00h,0,0,0,0,0,48,0,0,0,0,0
		invoke Drawline2, 20, 0, 448, 0,0,0,0,0d00h,0,0,0,0,0,0d00h,0,0,0,0,0,0d00h,0,0,0d00h
		

		invoke TransparentBlt, hdcMem, 128, 48, 384, 64, hdcPic, 256, 192, 192, 32, 08000H


		;��DrawMainһ�����Ȼ��Ƽ���ѡ��
		push 17h
		push 16h
		push 15h
		push 14h
		push rect1Top
		push rect1Left
		push 4
		call DrawLine
	
		push 1Fh
		push 0Eh
		push 1Dh
		push 1Ch
		push rect2Top
		push rect1Left
		push 4
		call DrawLine
		
		push 25h
		push 24h
		push 35h
		push 27h
		push rect3Top
		push rect1Left
		push 4
		call DrawLine
		
		push 34h
		push 1Eh
		push 27h
		push 26h
		push rect4Top
		push rect1Left
		push 4
		call DrawLine
		
		push 2Fh
		push 0Eh
		push 2Dh
		push 2Ch
		push rect5Top
		push rect1Left
		push 4
		call DrawLine
		jmp DrawMenuSelect
		
		;���������ƣ�ͬDrawMain
	DrawResult:

		invoke Drawline2, 20, 0, 0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 32, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 64, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 96, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 128, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 160, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 192, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 224, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 256, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,0,0,0
		invoke Drawline2, 20, 0, 288, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 320, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 352, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 384, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 416, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 448, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


		invoke Drawline2, 20, 0, 0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 32, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 64, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 96, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 128, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		invoke Drawline2, 20, 0, 160, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2
		invoke Drawline2, 20, 0, 192, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,4,5,4,5
		invoke Drawline2, 20, 0, 224, 0,0,0,0,0,0,0,0,0,0,48,0,0,2,3,4,5,6,5,4
		invoke Drawline2, 20, 0, 256, 0,0,0,0,0,0d00h,0,0,0d00h,0,0,0,2,3,4,5,40,5,4,3
		invoke Drawline2, 20, 0, 288, 0,0,0,0d00h,0d00h,0,0,48,0,0,0d00h,0,0,2,3,4,5,6,5,4
		invoke Drawline2, 20, 0, 320, 0,0c00h,0,0,0d00h,0,0d00h,0,0,0,48,0,0,0,2,2,2,2,2,2
		invoke Drawline2, 20, 0, 352, 0,0d00h,0,18,0,0,0d00h,0,0,48,0,0,0,0,0,0,0d00h,0,0,0
		invoke Drawline2, 20, 0, 384, 0,0,0e00h,0,0,0,0,0,0d00h,0,0d00h,0,0,0d00h,0,0d00h,0,0,0d00h,0
		invoke Drawline2, 20, 0, 416, 0,0d00h,0,0,0,0d00h,0,0,0d00h,0,0,0,0,0,48,0,0,0,0,0
		invoke Drawline2, 20, 0, 448, 0,0,0,0,0d00h,0,0,0,0,0,0d00h,0,0,0,0,0,0d00h,0,0,0d00h
	
		;invoke Drawline2, 20, 0, 0, 110000b,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	
		push 36H
		push 2Eh
		push 0Bh
		push 09h
		push 96
		push 256
		push 4
		call DrawLine
	
		push 2Fh
		push 0Eh
		push 2Dh
		push 2Ch
		push rect1Top
		push rect1Left
		push 4
		call DrawLine
	
		push 0Bh
		push 09h
		push 36H
		push 2Eh
		push rect2Top
		push rect1Left
		push 4
		call DrawLine
	
		jmp DrawMenuSelect
		
		
		;��Ϸ�������
	DrawGame:	
		call DrawGround	;���Ƶ��棬�ڵײ�ĺڱ������ٻ�һ�㱳��
		call DrawWall	;����ǽ��
		call DrawEnemyAndBullet	;����̹�ˡ�������ӵ�
		;call DrawTree	;������
		call DrawSideBar;���Ƶ÷ְ�
		
		jmp DrawUIReturn
	
		;ѡ���ͷ����
	DrawMenuSelect:
		;��ͷ����
		mov eax,SelectMenu
		sal eax,5	;y��ƫ��
		add eax,160
		push eax
		push 220	;x��ƫ��
		push 10		;ͼƬ���
		call DrawSpirit
		
	DrawUIReturn:
		ret

;���ư��ͼƬ
DrawHalfSpirit proc
		push ebp
		mov ebp,esp
		push ecx
		push edx

		mov eax,[ebp+8]
		mov ebx,eax
		sar eax,3
		and ebx,7h
		sal eax,5
		sal ebx,5
		
		mov ecx,[ebp+12]

		;push 0FF00h
		push 08000H
		push [DrawHalfSpiritMask+16+ecx*4]	;+16
		push [DrawHalfSpiritMask+ecx*4]
		push eax
		push ebx
		push hdcPic
		push [DrawHalfSpiritMask+16+ecx*4]	;+16
		push [DrawHalfSpiritMask+ecx*4]
		mov edx,[DWORD PTR ebp+20]
		add edx,[DrawHalfSpiritMask+48+ecx*4]
		push edx
		mov edx,[DWORD PTR ebp+16]
		add edx,[DrawHalfSpiritMask+32+ecx*4];32
		push edx
		push hdcMem
		call TransparentBlt

		pop edx
		pop ecx
		mov esp,ebp
		pop ebp

		ret 16
DrawHalfSpirit endp

;����һ��ͼƬ
DrawSpirit proc
		push ebp
		mov ebp,esp

		mov eax,[ebp+8]
		mov ebx,eax

		cmp ebx, 100h
		jge newsite
		sar eax,3
		and ebx,7h
		jmp sitedown
		newsite:
		sar eax,12
		sar ebx,8
		and ebx,0fh
		sitedown:
		sal eax,5
		sal ebx,5

		invoke TransparentBlt, hdcMem, [DWORD PTR ebp+12], [DWORD PTR ebp+16], 32, 32, hdcPic, ebx, eax, 32, 32, 08000H

		mov esp,ebp
		pop ebp

		ret 12
DrawSpirit endp

;����һ��ͼƬ����װDrawSpirit��
DrawLine proc
		mov ecx,[esp+4]
		cmp ecx,0
		je DrawLineReturn

		push ebp
		mov ebp,esp
		cmp ecx,0
		mov esi,ebp
		add esi,20
		mov eax,[ebp+12]

	DrawLineLoop:
		push ecx
		push eax
		
		push [ebp+16]
		push eax
		push [esi]
		call DrawSpirit

		pop eax
		pop ecx
		add esi,4
		add eax,32
		loop DrawLineLoop
		
		mov esp,ebp
		pop ebp
		sub esi,16
		mov eax,[esp]
		mov esp,esi
		mov [esp],eax

	DrawLineReturn:
		ret 12
DrawLine endp

;���Ƽ�ͷ
UpInMenu proc
		dec SelectMenu
		cmp SelectMenu,0
		jnl UpInMenuReturn
		mov SelectMenu,0	
	UpInMenuReturn:
		ret
UpInMenu endp
;���Ƽ�ͷ
DownInMenu proc
		push eax
		inc SelectMenu
		mov ebx,WhichMenu
		mov eax,[ButtonNumber+ebx*4]
		dec eax
		cmp SelectMenu,eax
		jng DownInMenuReturn
		mov SelectMenu,eax
	DownInMenuReturn:
		pop eax
		ret
DownInMenu endp

;enter/space����Ӧ		
EnterInMenu proc
		push eax
		;��һ���֧���жϵ�ǰ��������
		cmp WhichMenu,2	;��Ϸ���棬ֱ��������֧
		je EnterInMenuReturn
		mov SpaceKeyHold,0;�������ӵ�������������
		mov EnterKeyHold,0
		.IF WhichMenu == 0 ; ��ʼ����
			jmp EnterInMain
		.ELSEIF WhichMenu == 1 ; ģʽѡ��
			jmp EnterInMode
		.ELSEIF WhichMenu == 3 ; ��������
			jmp EnterInResult
		.ELSE ; �������������Ϸ
			jmp EnterToEndGame
		.ENDIF

		;�ڶ����֧
	EnterInMain:
		cmp SelectMenu,0
		je EnterToMode;0 ��Ӧѡ��ģʽ
		cmp SelectMenu,1
		je EnterToEndGame;�������1 ��Ӧ�˳���Ϸ
		jmp EnterToEndGame

		;1�Ž���ת�ƣ�ģʽѡ��
	EnterInMode:
		cmp SelectMenu,4;4�����ϲ�
		je EnterToMain
		jmp EnterToGame ;ת�Ƶ���Ϸ����
		jmp EnterInMenuReturn

		;3�Ž���ת�ƣ�������棩
	EnterInResult:
		cmp SelectMenu,0
		je EnterToMain
		jmp EnterToEndGame

		;ת����ʼ����
	EnterToMain:
		mov WhichMenu,0
		mov SelectMenu,0
		jmp EnterInMenuReturn
	
		;ת��ģʽѡ��
	EnterToMode:
		mov WhichMenu,1
		jmp EnterInMenuReturn

		;ת����Ϸ����
		;ת��ǰ����ģʽ��ֵ
	EnterToGame:
		mov eax,SelectMenu
		and eax,1;ȡSelectMenu���һλ
		mov GameMode,eax;0��2���0����Ӧ����ģʽ��1,3���1����Ӧ��սģʽ
		mov eax,SelectMenu
		sar eax,1;�������ƣ�00b��01b������00b����Ӧ����ģʽ,10b��11b������11b����Ӧ˫��ģʽ
		mov IsDoublePlayer,eax	
		mov WhichMenu,2
		call ResetField
		jmp EnterInMenuReturn

		;�˳���Ϸ
	EnterToEndGame:
		push 0
		call PostQuitMessage
		push 1
		push hMainWnd
		call KillTimer
	
	EnterInMenuReturn:
		pop eax
		ret
EnterInMenu endp

;�˳���Ϸ
EnterToEndGame:
	push 0
	call PostQuitMessage
	push 1
	push hMainWnd
	call KillTimer
	pop eax
	ret

;esc����Ӧ
EscapeInMenu proc
		mov SelectMenu,0
		mov WhichMenu,0
		ret
EscapeInMenu endp

;��������
ResetField:
		mov [Score],0
		mov [Score+4],0
		mov eax,GameMode
		mov ebx,1
		sub ebx,eax
		mov [Round],ebx	
		mov [YourLife],5	
		mov [YourLife+4],5
		mov YouDie,0
		call NewRound
		ret

;��ʼ��
NewRound:
		mov WaitingTime,-1
		;���1
		mov [YourRole],1	
		mov [YourRole+4],128;̹�����Ƶ��߽�,��ʼλ�ú�����
		mov [YourRole+8],448;̹�˳�ʼλ��������
		mov [YourRole+12],3 ;̹�˳�ʼ����0���ң�˳ʱ������0-3
		mov [YourRole+16],7 ;�ӵ�����
		;���2
		mov [YourRole+32],2
		mov [YourRole+36],320
		mov [YourRole+40],448
		mov [YourRole+44],3
		mov [YourRole+48],0
		;�ж��Ƿ�˫�ˣ�˫�˾Ͱ����2��־��0���������Ƶ�ʱ��Ͳ�������2������ݽ��л���
		cmp IsDoublePlayer,0
		jne InitEnemyLife
		mov [YourRole+32],0
		mov [YourLife+4],0

		;��ʼ��
	InitEnemyLife:
		mov eax,[Round]
		mov ebx,12
		mul ebx
		mov ebx,eax	

		mov eax,[RoundEnemy+ebx] ;���ݹؿ���ʼ�����ֵֹ�������
		mov [EnemyLife],eax
		mov eax,[RoundEnemy+ebx+4]
		mov [EnemyLife+4],eax
		mov eax,[RoundEnemy+ebx+8]
		mov [EnemyLife+8],eax
		
		;��չֺ��ӵ�
		mov ecx,10	
		mov esi,offset Enemy
	RemoveEnemy:
		mov DWORD ptr [esi],0	;��ǹ�Ϊ0������
		mov DWORD ptr [esi+16],0;����ӵ�Ϊ0������
		add esi,32				;����һ��
		loop RemoveEnemy
		
		;��ʼ����ͼ
		mov eax,[Round]
		mov ebx,225*4
		mul ebx
		mov ebx,eax	
		mov ecx,225	;��Ӧ225����ͼ�飬ѭ��225�Σ���RoundMap��Round��Ӧ�ĵ�ͼ�ŵ�Map��
	SetMap:
		mov eax,[RoundMap+ebx+ecx*4-4]
		mov [Map+ecx*4-4],eax
		loop SetMap

		ret

;���Ƶ���
DrawGround:
		mov ecx,225
	DrawGroundLoop:
		mov edx,0
		mov eax,ecx
		dec eax
		mov esi,15
		div esi
		sal edx,5
		sal eax,5
		add edx,80
		cmp [Map+ecx*4-4],1	
		je DrawGroundWater
		
		push ecx
		push eax
		push edx
		push 0
		call DrawSpirit
		pop ecx
	
		loop DrawGroundLoop
		jmp DrawGroundReturn
		
	DrawGroundWater:
	
		push ecx
		mov ebx,[WaterSpirit]
		sar ebx,2
		sar eax,5
		sar edx,5
		add ebx,eax
		add ebx,edx
		and ebx,3
		add ebx,3
		sal eax,5
		sal edx,5
		add edx,16
		push eax
		push edx
		push ebx
		call DrawSpirit
		pop ecx
		
		loop DrawGroundLoop
		
	DrawGroundReturn:
		ret

DrawWall:
		mov ecx,225
	DrawWallLoop:
		mov edx,0
		mov eax,ecx ;eax=225
		dec eax
		mov esi,15
		div esi
		sal edx,5
		sal eax,5
		add edx,80
		
		;�жϵ�ͼ�����е�ֵ������һ����Ȼ��ȥ��Ӧ�ĺ������л���
		test [Map+ecx*4-4],4 
		jnz DrawWallHalf
		cmp [Map+ecx*4-4],3	;ǽ��
		je DrawWallBlock
		cmp [Map+ecx*4-4],11;��ǽ��
		je DrawWallMetal
		cmp [Map+ecx*4-4],8	;��������
		je DrawWallBase
		
	DrawWallDoLoop:
		loop DrawWallLoop
		jmp DrawWallReturn
	
	DrawWallBlock:
		push ecx
		push eax
		push edx
		push 1
		call DrawSpirit
		pop ecx
		jmp DrawWallDoLoop
	
	DrawWallMetal:
		push ecx
		push eax
		push edx
		push 2
		call DrawSpirit
		pop ecx
		jmp DrawWallDoLoop

	DrawWallBase:
		push ecx
		push eax
		push edx
		push 8
		call DrawSpirit
		pop ecx
		jmp DrawWallDoLoop
		
	DrawWallHalf:
		test [Map+ecx*4-4],8
		jnz DrawMetalWallHalf
		mov ebx,[Map+ecx*4-4]
		and ebx,3

		push ecx
		push eax
		push edx
		push ebx  ;0
		push 1
		call DrawHalfSpirit 
		pop ecx
		jmp DrawWallDoLoop

	DrawMetalWallHalf:
		mov ebx,[Map+ecx*4-4]
		and ebx,3
		push ecx
		push eax
		push edx
		push ebx
		push 2
		call DrawHalfSpirit
		pop ecx
		jmp DrawWallDoLoop

	DrawWallReturn:
		ret

DrawEnemyAndBullet:
;���ƹֺ��ӵ�������YourRole�Ĳ�����ѡ���Ӧ��λͼ��ʵ�ֻ���
		mov esi,offset YourRole
		mov ecx,12	;���Ĺ���Ŀ
	DrawEnemyAndBulletLoop:
		push esi
		mov eax,0
		cmp [esi],eax;���Ƿ�Ϊ0
		je GoToDrawBulletIThink
		push ecx
		mov eax,[esi];�ڼ��ֹ�
		inc eax
		sal eax,3
		;�ҵ�λͼ�еĵ�ַ
		add eax,[esi+12]
		mov ebx,[esi+4]
		add ebx,80
		
		push [esi+8]
		push ebx
		push eax
		;��λ�á���ʼ����ѹ��ջ ʹ��drawspirit������
		call DrawSpirit
		pop ecx

	GoToDrawBulletIThink:
		mov esi,[esp];Ӧ�û���esi
		add esi,16	;��ת���ӵ�����������
		mov eax,0
		cmp [esi],eax	;�Ƿ�Ϊ0�������ڣ�
		je DrawEnemyAndBulletLoopContinue
		push ecx
		mov eax,[esi]
		add eax,54
		mov ebx,[esi+4]
		add ebx,80

		push [esi+8]
		push ebx
		push eax
		call DrawSpirit
		pop ecx
		
	DrawEnemyAndBulletLoopContinue:
		pop esi
		add esi,32	;��ת����һ��������л���
		loop DrawEnemyAndBulletLoop
		ret


DrawSideBar:
;���߿��������
		mov ecx,IsDoublePlayer
		inc ecx
		mov eax,64
		mov ebx,07h
		mov esi,offset YourLife ;����ֵ
	DrawSideBarLoop:
		push esi
		push ebx
		push ecx
		push eax

		;push eax
		.IF ecx == 1
		push 64
		push 8
		.ELSE
		push 64
		push 568
		.ENDIF
		push ebx	;16
		call DrawSpirit
		
		;��������
		mov eax,[esi]
		mov edx,0
		mov ebx,10
		div ebx
		add edx,30h	;48
		mov ScoreText,dl
		
		mov eax,[esp]
		add eax,8
	
		pop eax
		pop ecx
		push ecx
		push eax
	
		push 1
		push offset ScoreText
		.IF ecx == 1
		push 70
		push 48
		.ELSE
		push 70
		push 608
		.ENDIF
		push hdcMem
		call TextOut
		
		pop eax
		pop ecx
		pop ebx
		pop esi
		add esi,4
		add eax,48
		loop DrawSideBarLoop
		
		mov eax,0
	.IF GameMode == 0
		ret
	.ENDIF
	DrawSideBarRepeat:
	;���Ƶ÷ְ�
		push eax
		sal eax,6
		add eax,320
		push 0900h
		push 0800h
		;push eax
		;push 568
		.IF eax == 140H
		push 120
		push 8	
		.ELSE
		push 120
		push 568
		.ENDIF
		push 2
		call DrawLine
		
		;���µ÷ְ�
		mov esi,[esp]			;�����������
		mov eax,[Score+4*esi]	;������Ҷ�Ӧ�ķ���
		mov esi,offset ScoreText;esi��Ӧ�������ַ���
		add esi,5
		mov ecx,6
		mov ebx,10
	DrawSideBarGetScoreText:
	;��score�е�����ת��Ϊ�ַ�����ڶ�Ӧ��scoretest��
		mov edx,0
		div ebx
		add edx,30h
		mov [esi],dl
		dec esi
		loop DrawSideBarGetScoreText
	
		;���Ʒ�����
		mov edi,[esp]
		sal edi,6
		add edi,360
		push 6
		push offset ScoreText
		;push edi
		;push 576
		.IF edi == 168H
		push 160
		push 8	
		.ELSE
		push 160
		push 568
		.ENDIF
		push hdcMem
		call TextOut
		
		pop eax
		.IF IsDoublePlayer == 0
			ret
		.ENDIF
		cmp eax,0
		mov eax,1
		je DrawSideBarRepeat
	
		ret

;TODO���ݰ��µİ����޸�״̬���޸ĺ���PaintMessage���DrawUIˢ��
TimerTick:
		cmp WaitingTime,0
		jl DontWait
		je ChangeGame
		dec WaitingTime
		jmp DontWait
	ChangeGame:
		cmp YouDie,1
		jne NotGameOver
		mov WhichMenu,3
		mov SelectMenu,0
	NotGameOver:
		call NewRound
		mov WaitingTime,-1
	DontWait:

		inc WaterSpirit
		and WaterSpirit,0Fh

		cmp WhichMenu,2
		je TimerTickDontReturn
		jmp TimerTickReturn
	TimerTickDontReturn:
		
		cmp UpKeyHold,1
		jne TT@1
		mov [YourRole+12],3
		sub [YourRole+8],4
		push offset YourRole
		push 1
		call CheckCanGo
		test eax,1
		jz TT@1Bad
		invoke GetMyRect, offset YourRole
		push offset YourRole
		push edx
		push ecx
		push ebx
		push eax
		call GetInRect
		cmp eax,0
		je TT@4
	TT@1Bad:
		add [YourRole+8],4
		jmp TT@4
	TT@1:
		cmp DownKeyHold,1
		jne TT@2
		mov [YourRole+12],1
		add [YourRole+8],4
		push offset YourRole
		push 1
		call CheckCanGo
		test eax,1
		jz TT@2Bad
		invoke GetMyRect, offset YourRole
		push offset YourRole
		push edx
		push ecx
		push ebx
		push eax
		call GetInRect
		cmp eax,0
		je TT@4
	TT@2Bad:
		sub [YourRole+8],4
		jmp TT@4
	TT@2:
		cmp LeftKeyHold,1
		jne TT@3
		mov [YourRole+12],2
		sub [YourRole+4],4
		push offset YourRole
		push 1
		call CheckCanGo
		test eax,1
		jz TT@3Bad
		invoke GetMyRect, offset YourRole
		push offset YourRole
		push edx
		push ecx
		push ebx
		push eax
		call GetInRect
		cmp eax,0
		je TT@4
	TT@3Bad:
		add [YourRole+4],4
		jmp TT@4
	TT@3:
		cmp RightKeyHold,1
		jne TT@4
		mov [YourRole+12],0
		add [YourRole+4],4
		push offset YourRole
		push 1
		call CheckCanGo
		test eax,1
		jz TT@4Bad
		invoke GetMyRect, offset YourRole
		push offset YourRole
		push edx
		push ecx
		push ebx
		push eax
		call GetInRect
		cmp eax,0
		je TT@4
	TT@4Bad:
		sub [YourRole+4],4
		jmp TT@4
	TT@4:
		cmp EnterKeyHold,1
		je TT@5@@
		cmp SpaceKeyHold,1
		jne TT@5
		cmp IsDoublePlayer,0
		jne TT@5
	TT@5@@:
		cmp DWORD ptr [YourRole+16],0
		jne TT@5
		cmp DWORD ptr [YourRole],0
		je TT@5
		mov ebx,[YourRole+12]
		mov [YourRole+16],1
		mov eax,[YourRole+4]
		add eax,[BulletPosFix+4*ebx]
		mov [YourRole+20],eax
		mov eax,[YourRole+8]
		add eax,[BulletPosFix+16+4*ebx]
		mov [YourRole+24],eax
		mov eax,[YourRole+12]
		mov [YourRole+28],eax
	TT@5:
	
		cmp WKeyHold,1
		jne TT@6
		mov [YourRole+12+32],3
		sub [YourRole+8+32],4
		push offset YourRole+32
		push 1
		call CheckCanGo
		test eax,1
		jz TT@6Bad
		invoke GetMyRect, offset YourRole+32
		push offset YourRole+32
		push edx
		push ecx
		push ebx
		push eax
		call GetInRect
		cmp eax,0
		je TT@9
	TT@6Bad:
		add [YourRole+8+32],4
		jmp TT@9
	TT@6:
		cmp SKeyHold,1
		jne TT@7
		mov [YourRole+12+32],1
		add [YourRole+8+32],4
		push offset YourRole+32
		push 1
		call CheckCanGo
		test eax,1
		jz TT@7Bad
		invoke GetMyRect, offset YourRole+32
		push offset YourRole+32
		push edx
		push ecx
		push ebx
		push eax
		call GetInRect
		cmp eax,0
		je TT@9
	TT@7Bad:
		sub [YourRole+8+32],4
		jmp TT@9
	TT@7:
		cmp AKeyHold,1
		jne TT@8
		mov [YourRole+12+32],2
		sub [YourRole+4+32],4
		push offset YourRole+32
		push 1
		call CheckCanGo
		test eax,1
		jz TT@8Bad
		invoke GetMyRect, offset YourRole+32
		push offset YourRole+32
		push edx
		push ecx
		push ebx
		push eax
		call GetInRect
		cmp eax,0
		je TT@9
	TT@8Bad:
		add [YourRole+4+32],4
		jmp TT@9
	TT@8:
		cmp DKeyHold,1
		jne TT@9
		mov [YourRole+12+32],0
		add [YourRole+4+32],4
		push offset YourRole+32
		push 1
		call CheckCanGo
		test eax,1
		jz TT@9Bad
		invoke GetMyRect, offset YourRole+32
		push offset YourRole+32
		push edx
		push ecx
		push ebx
		push eax
		call GetInRect
		cmp eax,0
		je TT@9
	TT@9Bad:
		sub [YourRole+4+32],4
		jmp TT@9
	TT@9:
		cmp SpaceKeyHold,1
		jne TT@10
		cmp DWORD ptr [YourRole+16+32],0
		jne TT@10
		cmp DWORD ptr [YourRole+32],0
		je TT@10
		mov ebx,[YourRole+12+32]
		mov [YourRole+16+32],1
		mov eax,[YourRole+4+32]
		add eax,[BulletPosFix+4*ebx]
		mov [YourRole+20+32],eax
		mov eax,[YourRole+8+32]
		add eax,[BulletPosFix+16+4*ebx]
		mov [YourRole+24+32],eax
		mov eax,[YourRole+12+32]
		mov [YourRole+28+32],eax
	TT@10:
		mov ecx,12
		lea esi,YourRole+16
		jmp TTLoopForBullet
		
	TTLoopForBulletContinue:
		add esi,32
		loop TTLoopForBullet
		jmp TTLoopForBulletDone
		
	TTLoopForBullet:
		cmp DWORD ptr [esi],0
		je TTLoopForBulletContinue
		cmp DWORD ptr [esi],1
		je TTBulletCanMove
		inc DWORD ptr [esi]
		cmp DWORD ptr [esi],10
		jl TTLoopForBulletContinue
		mov DWORD ptr [esi],0
		jmp TTLoopForBulletContinue
	TTBulletCanMove:
		mov ebx,[esi+12]
		mov eax,[esi+4]
		add eax,[BulletMove+4*ebx]
		mov [esi+4],eax
		mov eax,[esi+8]
		add eax,[BulletMove+16+4*ebx]
		mov [esi+8],eax
		push esi
		push ecx
		push esi
		push 0
		call CheckCanGo
		test eax,1
		jnz TTBreakDone
		mov esi,BreakWallType
		mov edi,BreakWallPos
		cmp edi,225
		jge TTBreakDone
		cmp esi,3
		je TTBreakWall
		cmp esi,11
		je TTBreakMetal
		test esi,4h
		jnz TTBreakHalf
		jmp TTBreakDone
	TTBreakMetal:
		mov esi,[esp+4]
		mov ebx,[esi-16]
		cmp ebx,4
		jne TTBreakDone
	TTBreakWall:
		mov esi,[esp+4]
		mov ebx,[esi+12]
		mov eax,[Map+edi*4]
		add eax,[DirectionMapToW+4*ebx]
		mov [Map+edi*4],eax
		mov eax,0
		jmp TTBreakDone
	TTBreakHalf:
		test esi,8h
		jz TTHalfNotMatel
		mov esi,[esp+4]
		mov ebx,[esi-16]
		cmp ebx,4
		jne TTBreakDone
	TTHalfNotMatel:
		mov [Map+edi*4],0
	TTBreakDone:
		pop ecx
		pop esi
		test eax,1
		jz TTBulletBoom
		push ecx
		
		push esi
		call GetBulletRect
		
		push esi
		sub esi,16
		push esi
		push edx
		push ecx
		push ebx
		push eax
		call GetInRect
		pop esi
		pop ecx
		cmp eax,0
		je TTCheckBulletDoom
		
		mov ebx,eax
		push esi
		push eax
		call FromOnePart
		test eax,1
		jz TTBulletHit
		jmp TTCheckBulletDoom
		
	TTBulletHit:
		mov edi,[ebx]
		mov DWORD ptr [ebx],0
		push ebx
		call IsEnemy
		cmp eax,1
		jne TTYouDie
		push esi
		sub esi,16
		sub esi,offset YourRole
		sar esi,3
		add [Score+esi],200
		sub edi,3
		sal edi,6
		add [Score+esi],edi
		pop esi
		call HaveEnemy
		test eax,1
		jnz TTBulletBoom
		cmp [EnemyLife],0
		jne TTBulletBoom
		cmp [EnemyLife+4],0
		jne TTBulletBoom
		cmp [EnemyLife+8],0
		jne TTBulletBoom
		mov WaitingTime,20
		inc DWORD ptr [Round]
		jmp TTBulletBoom
	TTYouDie:
		cmp DWORD ptr [YourLife],0
		jne TTBulletBoom
		cmp DWORD ptr [YourLife+4],0
		jne TTBulletBoom
		jmp TTYouReallyDie
		
	TTYouReallyDie:
		mov WaitingTime,20
		mov YouDie,1
		jmp TTBulletBoom
		
	TTCheckBulletDoom:
		push ecx
		push esi
		call GetBulletRect
		
		push esi
		push esi
		push edx
		push ecx
		push ebx
		push eax
		call GetBulletInRect
		pop esi
		pop ecx
		cmp eax,0
		je TTLoopForBulletContinue
		
		mov ebx,eax
		push esi
		push eax
		call FromOnePart
		test eax,1
		jnz TTLoopForBulletContinue
		inc DWORD ptr [ebx]

	TTBulletBoom:
		inc DWORD ptr [esi]
		jmp TTLoopForBulletContinue
	TTLoopForBulletDone:
		mov ebx,[Round]
		mov eax,[RoundSpeed+ebx*4]
		call RandomRange
		cmp eax,0
		jne TTCreateNewEnemyDone
		call CreateRandomEnemy
	TTCreateNewEnemyDone:
	
		mov ecx,10
		mov esi,offset Enemy
		jmp TTLoopForEnemy
	TTEnemyLoopEnd:
		add esi,32
		loop TTLoopForEnemy
		jmp TTEnemyLoopDone
		
	TTLoopForEnemy:
		cmp DWORD ptr [esi],0
		je TTEnemyLoopEnd
		mov ebx,[esi]
		sub ebx,3
		sal ebx,3
		add ebx,[esi+12]
		mov eax,[esi+4]
		add eax,[EnemyMove+4*ebx]
		mov [esi+4],eax
		mov eax,[esi+8]
		add eax,[EnemyMove+16+4*ebx]
		mov [esi+8],eax
		push esi
		push ecx
		push esi
		push 1
		call CheckCanGo
		pop ecx
		pop esi
		test eax,1
		jz TTEnemyCantGo

		push ecx
		push esi
		invoke GetMyRect, esi
		mov esi,[esp]
		push esi
		push edx
		push ecx
		push ebx
		push eax
		call GetInRect
		cmp eax,0
		pop esi
		pop ecx
		je TTEnemyCanGo

	TTEnemyCantGo:
		mov ebx,[esi]
		sub ebx,3
		sal ebx,3
		add ebx,[esi+12]
		mov eax,[esi+4]
		sub eax,[EnemyMove+4*ebx]
		mov [esi+4],eax
		mov eax,[esi+8]
		sub eax,[EnemyMove+16+4*ebx]
		mov [esi+8],eax
		mov eax,4
		call RandomRange
		mov [esi+12],eax
	TTEnemyCanGo:
	
		cmp DWORD ptr [esi+16],0
		jne TTEnemyDontShoot
		mov ebx,[esi+12]
		mov DWORD ptr [esi+16],1
		mov eax,[esi+4]
		add eax,[BulletPosFix+4*ebx]
		mov [esi+20],eax
		mov eax,[esi+8]
		add eax,[BulletPosFix+16+4*ebx]
		mov [esi+24],eax
		mov eax,[esi+12]
		mov [esi+28],eax
	TTEnemyDontShoot:
		jmp TTEnemyLoopEnd
	TTEnemyLoopDone:
		
		cmp DWORD ptr [Map+217*4],0
		je TTBeseNotThreatened
		push 0
		push 474
		push 250
		push 454
		push 230
		call GetBulletInRect
		cmp eax,0
		je TTBeseNotThreatened
		mov [Map+217*4],0
		mov DWORD ptr [eax],2
		mov YouDie,1
		mov WaitingTime,20
	TTBeseNotThreatened:
	
		cmp [YourRole],0
		jne TTYouDontNeedReset1
		cmp [YourLife],0
		jle TTYouDontNeedReset1
		push 0
		push 480
		push 160
		push 448
		push 128
		call GetBulletInRect
		cmp eax,0
		jne TTYouDontNeedReset1
		push 0
		push 480
		push 160
		push 448
		push 128
		call GetInRect
		cmp eax,0
		jne TTYouDontNeedReset1
		mov [YourRole],1
		mov [YourRole+4],128
		mov [YourRole+8],448
		mov [YourRole+12],3
		dec [YourLife]
	TTYouDontNeedReset1:
			
		cmp [YourRole+32],0
		jne TTYouDontNeedReset2
		cmp [YourLife+4],0
		jle TTYouDontNeedReset2
		push 0
		push 480
		push 352
		push 448
		push 320
		call GetBulletInRect
		cmp eax,0
		jne TTYouDontNeedReset2
		push 0
		push 480
		push 352
		push 448
		push 320
		call GetInRect
		cmp eax,0
		jne TTYouDontNeedReset2
		mov [YourRole+32],2
		mov [YourRole+4+32],320
		mov [YourRole+8+32],448
		mov [YourRole+12+32],3
		dec [YourLife+4]
	TTYouDontNeedReset2:
	
	TimerTickReturn:
		ret
		
FromOnePart:
		mov eax,1
		cmp DWORD ptr [esp+4],offset Enemy
		jb FOP1
		xor eax,1
	FOP1:
		cmp DWORD ptr [esp+8],offset Enemy
		jb FOP2
		xor eax,1
	FOP2:
		ret 8

IsEnemy:
		mov eax,0
		cmp DWORD ptr [esp+4],offset Enemy
		jb NoIsntEnemy
		mov eax,1
	NoIsntEnemy:
		ret 4

HaveEnemy:
		push ecx
		push esi
		mov eax,0
		mov ecx,10
		mov esi,offset Enemy
	HaveEnemyLoop:
		cmp DWORD ptr[esi],0
		je NoEnemy
		mov eax,1
		jmp HaveEnemyLoopDone
	NoEnemy:
		add esi,32
		loop HaveEnemyLoop
	HaveEnemyLoopDone:
		pop esi
		pop ecx
		ret

CreateRandomEnemy:
		mov eax,3
		call RandomRange
		mov edi,eax
		
		cmp DWORD ptr [EnemyLife+edi*4],0
		jle CreateEnemyRetry
		mov ecx,10
		mov esi,offset Enemy
		jmp SearchForIdle

	CreateEnemyRetry:
		cmp [EnemyLife],0
		jne CreateRandomEnemy
		cmp [EnemyLife+4],0
		jne CreateRandomEnemy
		cmp [EnemyLife+8],0
		jne CreateRandomEnemy
		jmp CreateRandomEnemyDone
	SearchForIdle:
		cmp DWORD ptr [esi],0
		je SearchForIdleDone
		add esi,32
		loop SearchForIdle
		jmp CreateRandomEnemyDone
	SearchForIdleDone:
		mov eax,3
		call RandomRange

		mov ebx,[RandomPlace+eax*4]

		push 0
		push 32
		add ebx,32
		push ebx
		push 0
		sub ebx,32
		push ebx
		call GetInRect
		cmp eax,0
		jne CreateRandomEnemyDone

		dec [EnemyLife+edi*4]
		add edi,3
		mov DWORD ptr [esi],edi
		mov DWORD ptr [esi+4],ebx
		mov DWORD ptr [esi+8],0
		mov DWORD ptr [esi+12],1
	CreateRandomEnemyDone:
		ret

GetInRect:
		push ebp
		mov ebp,esp
		push ecx
		push esi
		push ebx
		mov ecx,12
		mov esi,offset YourRole
	GetLoop:
		cmp DWORD ptr [esi],0
		je GetLoopContinue
		cmp esi,[ebp+24]
		je GetLoopContinue
		push ecx
		invoke GetMyRect, esi
		push edx
		push ecx
		push ebx
		push eax
		push [ebp+20]
		push [ebp+16]
		push [ebp+12]
		push [ebp+8]
		call RectConflict
		test eax,1
		pop ecx
		jnz GetLoopSucceed
	GetLoopContinue:
		add esi,32
		loop GetLoop
	GetLoopFail:
		mov eax,0
		jmp GetDone
	GetLoopSucceed:
		mov eax,esi
	GetDone:
		pop ebx
		pop esi
		pop ecx
		mov esp,ebp
		pop ebp
		ret 20
		

GetBulletInRect:
		push ebp
		mov ebp,esp
		push ecx
		push esi
		push ebx
		mov ecx,12
		mov esi,offset YourRole
		add esi,16
	GetBulletLoop:
		cmp DWORD ptr [esi],1
		jne GetBulletLoopContinue
		cmp esi,[ebp+24]
		je GetBulletLoopContinue
		push ecx
		push esi
		call GetBulletRect
		push edx
		push ecx
		push ebx
		push eax
		push [ebp+20]
		push [ebp+16]
		push [ebp+12]
		push [ebp+8]
		call RectConflict
		test eax,1
		pop ecx
		jnz GetBulletLoopSucceed
	GetBulletLoopContinue:
		add esi,32
		loop GetBulletLoop
	GetBulletLoopFail:
		mov eax,0
		jmp GetBulletDone
	GetBulletLoopSucceed:
		mov eax,esi
	GetBulletDone:
		pop ebx
		pop esi
		pop ecx
		mov esp,ebp
		pop ebp
		ret 20

		
CheckCanGo:
		push ebp
		mov ebp,esp
		mov esi,[ebp+12]
		cmp DWORD ptr [ebp+8],1
		jne CheckBulletCanGo

		invoke GetMyRect, esi
		jmp CheckEnemyCanGo
	CheckBulletCanGo:
	
		push esi
		call GetBulletRect
	CheckEnemyCanGo:
		mov BreakWallPos,1000
		cmp eax,0
		jl CheckCanGoFail
		cmp ebx,0
		jl CheckCanGoFail
		cmp ecx,480
		jg CheckCanGoFail
		cmp edx,480
		jg CheckCanGoFail
		
		sub esp,24
		mov [ebp-4],eax
		mov [ebp-8],ebx
		mov [ebp-12],ecx
		mov [ebp-16],edx
		
		mov esi,eax
		mov edi,ebx
		sar esi,5
		sar edi,5
		mov [ebp-20],esi
		mov [ebp-24],edi

		push [ebp+8]
		push [ebp-24]
		push [ebp-20]
		call GetBlockRect
		
		push edx
		push ecx
		push ebx
		push eax
		push [ebp-16]
		push [ebp-12]
		push [ebp-8]
		push [ebp-4]
		call RectConflict
		test eax,1
		jnz CheckCanGoFail

		inc DWORD ptr [ebp-20]
		push [ebp+8]
		push [ebp-24]
		push [ebp-20]
		call GetBlockRect
		
		push edx
		push ecx
		push ebx
		push eax
		push [ebp-16]
		push [ebp-12]
		push [ebp-8]
		push [ebp-4]
		call RectConflict
		test eax,1
		jnz CheckCanGoFail

		inc DWORD ptr [ebp-24]
		push [ebp+8]
		push [ebp-24]
		push [ebp-20]
		call GetBlockRect
		
		push edx
		push ecx
		push ebx
		push eax
		push [ebp-16]
		push [ebp-12]
		push [ebp-8]
		push [ebp-4]
		call RectConflict
		test eax,1
		jnz CheckCanGoFail

		dec DWORD ptr [ebp-20]
		push [ebp+8]
		push [ebp-24]
		push [ebp-20]
		call GetBlockRect
		
		push edx
		push ecx
		push ebx
		push eax
		push [ebp-16]
		push [ebp-12]
		push [ebp-8]
		push [ebp-4]
		call RectConflict
		test eax,1
		jnz CheckCanGoFail

		mov eax,1
		jmp CheckCanGoReturn
		
	CheckCanGoFail:
		mov eax,0
	CheckCanGoReturn:
		mov esp,ebp
		pop ebp
		ret 8

GetBulletRect:	; &bullet
		mov esi,[esp+4]
		mov eax,[esi+4]
		mov ebx,[esi+8]
		add eax,10
		add ebx,10
		mov ecx,eax
		mov edx,ebx
		add ecx,12
		add edx,12
		ret 4
		
GetMyRect proc role:DWORD
		mov esi,role;esi = YourRole
		mov eax,[esi+4];eax = x
		mov ebx,[esi+8];ebx = y
		add eax,4
		add ebx,4
		mov ecx,eax
		mov edx,ebx
		add ecx,24
		add edx,24;λ�þ����4������
		ret 4
GetMyRect endp
GetBlockRect:
		push ebp
		mov ebp,esp
		mov eax,[ebp+12]
		mov ebx,15
		mul ebx
		mov ebx,[ebp+8]
		add eax,ebx
		mov ebx,eax
		mov eax,[Map+ebx*4]
		mov BreakWallType,eax
		mov BreakWallPos,ebx
		cmp DWORD ptr [ebp+8],15
		jge NoBlock
		cmp DWORD ptr [ebp+12],15
		jge NoBlock
		cmp ebx,225
		jge NoBlock
		cmp eax,0
		je NoBlock
		cmp eax,2
		je NoBlock
		cmp eax,8
		je NoBlock
		cmp DWORD ptr [ebp+16],1
		je @@notbullet
		cmp eax,1
		je NoBlock
	@@notbullet:
		cmp eax,1
		je AllBlock
		cmp eax,3
		je AllBlock
		cmp eax,11
		je AllBlock
	
		and eax,3h
		mov esi,eax
		mov eax,[ebp+8]
		sal eax,5
		mov ebx,[ebp+12]
		sal ebx,5
		add eax,[DrawHalfSpiritMask+32+esi*4]
		add ebx,[DrawHalfSpiritMask+48+esi*4]
		mov ecx,eax
		mov edx,ebx
		add ecx,[DrawHalfSpiritMask+esi*4]
		add edx,[DrawHalfSpiritMask+16+esi*4]

		jmp GetBlockRectReturn
	AllBlock:
		mov eax,[ebp+8]
		sal eax,5
		mov ebx,[ebp+12]
		sal ebx,5
		mov ecx,eax
		add ecx,32
		mov edx,ebx
		add edx,32
		jmp GetBlockRectReturn
	NoBlock:
		mov eax,-1
		mov ebx,-1
		mov ecx,-1
		mov edx,-1
		jmp GetBlockRectReturn
	GetBlockRectReturn:
		mov esp,ebp
		pop ebp
		ret 12
		
RectConflict:	;r1x1,r1y1,r1x2,r1y2,r2x1,r2y1,r2x2,r2y2
		push ebp
		mov ebp,esp
		
		push [ebp+36]
		push [ebp+32]
		push [ebp+28]
		push [ebp+24]
		push [ebp+12]
		push [ebp+8]
		call PointInRect
		test eax,1
		jnz RectConflictSucceed

		push [ebp+36]
		push [ebp+32]
		push [ebp+28]
		push [ebp+24]
		mov eax,[ebp+20]
		dec eax
		push eax
		push [ebp+8]
		call PointInRect
		test eax,1
		jnz RectConflictSucceed

		push [ebp+36]
		push [ebp+32]
		push [ebp+28]
		push [ebp+24]
		push [ebp+12]
		mov eax,[ebp+16]
		dec eax
		push eax
		call PointInRect
		test eax,1
		jnz RectConflictSucceed

		push [ebp+36]
		push [ebp+32]
		push [ebp+28]
		push [ebp+24]
		mov eax,[ebp+20]
		dec eax
		push eax
		mov eax,[ebp+16]
		dec eax
		push eax
		call PointInRect
		test eax,1
		jnz RectConflictSucceed

		push [ebp+20]
		push [ebp+16]
		push [ebp+12]
		push [ebp+8]
		push [ebp+28]
		push [ebp+24]
		call PointInRect
		test eax,1
		jnz RectConflictSucceed

		push [ebp+20]
		push [ebp+16]
		push [ebp+12]
		push [ebp+8]
		mov eax,[ebp+36]
		dec eax
		push eax
		push [ebp+24]
		call PointInRect
		test eax,1
		jnz RectConflictSucceed

		push [ebp+20]
		push [ebp+16]
		push [ebp+12]
		push [ebp+8]
		push [ebp+28]
		mov eax,[ebp+32]
		dec eax
		push eax
		call PointInRect
		test eax,1
		jnz RectConflictSucceed

		push [ebp+20]
		push [ebp+16]
		push [ebp+12]
		push [ebp+8]
		mov eax,[ebp+36]
		dec eax
		push eax
		mov eax,[ebp+32]
		dec eax
		push eax
		call PointInRect
		test eax,1
		jnz RectConflictSucceed

		mov eax,0
		jmp RectConflictFail
	RectConflictSucceed:
		mov eax,1
	RectConflictFail:
		mov esp,ebp
		pop ebp
		ret 32

PointInRect:	;x1,y1,rx1,ry1,rx2,ry2
		mov eax,0
		mov ebx,[esp+4]
		mov ecx,[esp+8]
		cmp [esp+12],ebx
		jg PointInRectFail
		cmp [esp+20],ebx
		jle PointInRectFail
		cmp [esp+16],ecx
		jg PointInRectFail
		cmp [esp+24],ecx
		jle PointInRectFail
		mov eax,1
	PointInRectFail:
		ret 24


Startup proc

		.IF bkColor == 010101H
			mov isStart, 0
			ret
		.ENDIF
		invoke TransparentBlt, hdcMem, 0, 0, 640, 480, hdcStart, 0, 0, 640, 480, 000000h
		.IF waitStart == 0
			sub bkColor, 020202H
			ret
		.ENDIF
		sub waitStart, 1
		ret

Startup endp

Drawline2 PROC num:DWORD, X:DWORD, Y:DWORD,arg1:DWORD,arg2:DWORD,arg3:DWORD,arg4:DWORD,arg5:DWORD,arg6:DWORD,arg7:DWORD,arg8:DWORD,arg9:DWORD,arg10:DWORD,arg11:DWORD,arg12:DWORD,arg13:DWORD,arg14:DWORD,arg15:DWORD,arg16:DWORD,arg17:DWORD,arg18:DWORD,arg19:DWORD,arg20:DWORD 
    ; ������
    ; �������ʹ�ò��������� mov eax, arg1
    	push arg1
    	push arg2
    	push arg3
    	push arg4
    	push arg5
    	push arg6
    	push arg7
    	push arg8
    	push arg9
    	push arg10
    	push arg11
    	push arg12
    	push arg13
    	push arg14
    	push arg15
    	push arg16
    	push arg17
    	push arg18
    	push arg19
    	push arg20
    	push Y
    	push X
    	push num
    	call DrawLine
    ret
Drawline2 ENDP


END WinMain