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
WindowName BYTE "北理工的恶龙", 0
className BYTE "BIT", 0

;套用创建窗口的模板
;创建一个窗口
MainWin WNDCLASS <NULL, WinProc, NULL, NULL, NULL, NULL, NULL, COLOR_WINDOW, NULL, className>

msg MSGStruct <>	;消息结构，用户存放获取的message
winRect RECT <>
hMainWnd DWORD ?	;主窗口的句柄
hInstance DWORD ?

hbitmap DWORD ?		;图片的句柄
hdcMem DWORD ?		;hdc句柄，使用频率高
hdcPic DWORD ?		;hdc句柄，很少使用
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

WaterSpirit DWORD ?				; 水的图片
WhichMenu DWORD 0				; 界面选项，0 开始，1 选择游戏模式，2 正在游戏，3 游戏结束
ButtonNumber DWORD 2, 5, 0, 2	; 各个界面下的选项个数
SelectMenu DWORD 0				; 正在选择的菜单项
GameMode DWORD 0				; 游戏模式 0为闯关模式，1为挑战模式
IsDoublePlayer DWORD 0			; 游戏模式，00是单人游戏，11是双人游戏

;键盘操作，按下变为1
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


;鼠标操作定位
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

;启动！
waitStart DWORD 1Fh		;启动前的起手
isStart DWORD 1			;启动后不需要再启动
bkColor DWORD 0ffffffh	;启动时的颜色


; Map储存了当前游戏阶段的地图，随着游戏关卡变化而不断变化
;0表示空，1是湖面，3是墙体，11是厚墙体，8是基地
Map			DWORD 225 DUP(?)

;YourRole，一行对应一个玩家，一列对应一个属性
;类型(0=不存在,1=玩家,2=未使用,3=普通,4=强化,5=快速)
;X
;Y
;方向
;子弹类型(0=不存在,1=存在,2~9=爆炸)
;子弹X
;子弹Y
;子弹方向
YourRole	DWORD 0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0
			
;Enemy的行数（10）决定了同时能出现的怪物数量
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
Round		DWORD 0	;Round决定了你用哪个地图，0对应无尽模式，12345对应挑战模式的5个关卡
WaitingTime	DWORD -1
YouDie		DWORD 0	;0代表存活，1代表死亡

;RoundMap存放了预留的地图
			;无尽关卡
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
			;关卡1                                  
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
			;关卡2
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
			;关卡3
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
			;关卡4
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
			;关卡5
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

;RoundEnemy以三个为一节，规定了某个关卡中三种怪的总数
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

;回调函数，用于响应窗口上产生的一切事件，比如鼠标，键盘等
WinProc proc
	push ebp		;被调用者保存寄存器
	mov ebp,esp		;栈顶指针%esp
	;第一级分支结构，根据基本事件类型转到不同分支
	mov eax,[ebp+12]	;取message参数
	;鼠标操作
	.IF eax == WM_LBUTTONDOWN
		;获取鼠标坐标
		mov     eax, [ebp+20]
		movzx   ebx, ax
		shr     eax, 16
		invoke ProcessMouseClick, ebx, eax
	.ENDIF

	.IF eax == WM_KEYDOWN
		; 按下键盘，将对应的 Hold 变量赋 1，且进行对应操作
		jmp KeyDownMessage
	.ELSEIF eax == WM_KEYUP
		; 松开键盘，将对应的 Hold 变量赋 0
		jmp KeyUpMessage
	.ELSEIF eax == WM_CREATE
		; 在程序运行之初，初始化窗口
		jmp CreateWindowMessage
	.ELSEIF eax == WM_CLOSE
		; 点击窗口右上角×号，关闭窗口，退出程序，同时销毁后台的计时器
		jmp CloseWindowMessage
	.ELSEIF eax == WM_PAINT
		; 任何对窗口的更改，都会产生一个 WM_PAINT 消息（包括定时器也会触发 WM_PAINT）
		jmp PaintMessage
	.ELSEIF eax == WM_TIMER
		; 计时器事件，每隔一段时间重新绘制窗口（基本和 PaintMessage 交替出现）
		jmp TimerMessage
	.ELSE
		; 交由默认回调函数处理
		jmp OtherMessage
	.ENDIF

	
		;第二级分支，通过判断具体事件类型转到不同分支
		;按键下压
	KeyDownMessage:
		mov eax,[ebp+16]
		cmp eax,38
		jne nup1
		invoke UpInMenu;上
		mov UpKeyHold,1
	nup1:
		cmp eax,40
		jne ndown1
		invoke DownInMenu;下
		mov DownKeyHold,1
	ndown1:
		cmp eax,37
		jne nleft1
		mov LeftKeyHold,1;左
	nleft1:
		cmp eax,39
		jne nright1
		mov RightKeyHold,1;右
	nright1:
		cmp eax,32
		jne nspace1
		mov SpaceKeyHold,1
		invoke EnterInMenu;空格
	nspace1:
		cmp eax,13
		jne nenter1
		mov EnterKeyHold,1
		invoke EnterInMenu;回车
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
		jmp WinProcExit;不需要处理的键
		
		;按键释放
		;结构同按键下压
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

		; 为当前窗口加一个计时器，计时器会不断发出计时器事件
		invoke SetTimer, hMainWnd, 1, 30, NULL

		; 获取环境上下文句柄
		invoke GetDC, hMainWnd
		mov hdc, eax  ; 返回当前窗口工作区DC句柄

		; 从这里开始加入新东西
		invoke CreateCompatibleDC, hdc  ; 环境兼容化：创建一个与指定设备兼容的内存设备上下文环境（DC）
		mov hdcStart, eax

		invoke LoadImageA, hInstance, 1002, 0,0,0,0
		mov hbitmap, eax  ; 返回资源图句柄

		invoke SelectObject, hdcStart, hbitmap  ; 把位图放到DC中

		invoke CreateCompatibleDC, hdc  ; 环境兼容化：创建一个与指定设备兼容的内存设备上下文环境（DC）
		mov hdcPic, eax  ; 兼容的内存DC句柄（相当于生成个画布）

		invoke CreateCompatibleDC, hdc  ; 环境兼容化：创建一个与指定设备兼容的内存设备上下文环境（DC）
		mov hdcPic, eax  ; 兼容的内存DC句柄（相当于生成个画布）

		invoke LoadImageA, hInstance, 1001, 0,0,0,0
		mov hbitmap, eax

		invoke SelectObject, hdcPic, hbitmap

		invoke CreateCompatibleDC, hdc
		mov hdcMem, eax

		invoke CreateCompatibleBitmap, hdc, 640,480
		mov hbitmap, eax  ; 返回创造好的位图的句柄

		invoke SelectObject, hdcMem, hbitmap

		invoke SetTextColor, hdcMem, 0FFFFFFh  ; 设置新地图的文本颜色

		invoke SetBkColor, hdcMem, 0  ; 设置背景颜色 黑色

		invoke ReleaseDC, hMainWnd, hdc

		jmp WinProcExit


	; 关闭窗口
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

		; 加入启动画面
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

		;计时器事件
	TimerMessage:
		call TimerTick

		invoke RedrawWindow, hMainWnd, NULL, NULL, 1

		jmp WinProcExit

	; 默认回调函数
	OtherMessage:    
		invoke DefWindowProc, [ebp+8], [ebp+12], [ebp+16], [ebp+20]

	WinProcExit:
		mov esp, ebp
		pop ebp
		ret 16
Winproc endp

;鼠标控制
ProcessMouseClick proc mouseX:DWORD, mouseY:DWORD
	.IF	WhichMenu == 0
	;开始游戏
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
	; 结束游戏
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
	;依次选择不同模式
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
	;开始游戏
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
    ; 结束游戏
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
		;第一级分支：根据WhichMenu变量判断当前所处界面，转到对应的绘制分支
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

	;主界面绘制
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


		;绘制第一行
		push 0Fh
		push 0Eh
		push 0Dh
		push 0Ch
		push rect1Top
		push rect1Left
		push 4
		call DrawLine
		;绘制第二行
		push 0Bh
		push 09h
		push 36H
		push 2Eh
		push rect2Top
		push rect1Left
		push 4
		call DrawLine
		jmp DrawMenuSelect
		
		;选择界面绘制
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


		;和DrawMain一样，先绘制几行选项
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
		
		;结算界面绘制，同DrawMain
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
		
		
		;游戏界面绘制
	DrawGame:	
		call DrawGround	;绘制地面，在底层的黑背景上再画一层背景
		call DrawWall	;绘制墙体
		call DrawEnemyAndBullet	;绘制坦克、怪物和子弹
		;call DrawTree	;绘制树
		call DrawSideBar;绘制得分板
		
		jmp DrawUIReturn
	
		;选项箭头绘制
	DrawMenuSelect:
		;箭头绘制
		mov eax,SelectMenu
		sal eax,5	;y轴偏移
		add eax,160
		push eax
		push 220	;x轴偏移
		push 10		;图片标号
		call DrawSpirit
		
	DrawUIReturn:
		ret

;绘制半个图片
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

;绘制一个图片
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

;绘制一行图片（封装DrawSpirit）
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

;上移箭头
UpInMenu proc
		dec SelectMenu
		cmp SelectMenu,0
		jnl UpInMenuReturn
		mov SelectMenu,0	
	UpInMenuReturn:
		ret
UpInMenu endp
;下移箭头
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

;enter/space键响应		
EnterInMenu proc
		push eax
		;第一层分支，判断当前所处界面
		cmp WhichMenu,2	;游戏界面，直接跳出分支
		je EnterInMenuReturn
		mov SpaceKeyHold,0;不发射子弹则清零两个键
		mov EnterKeyHold,0
		.IF WhichMenu == 0 ; 初始界面
			jmp EnterInMain
		.ELSEIF WhichMenu == 1 ; 模式选择
			jmp EnterInMode
		.ELSEIF WhichMenu == 3 ; 结束界面
			jmp EnterInResult
		.ELSE ; 意外情况结束游戏
			jmp EnterToEndGame
		.ENDIF

		;第二层分支
	EnterInMain:
		cmp SelectMenu,0
		je EnterToMode;0 对应选择模式
		cmp SelectMenu,1
		je EnterToEndGame;否则就是1 对应退出游戏
		jmp EnterToEndGame

		;1号界面转移（模式选择）
	EnterInMode:
		cmp SelectMenu,4;4返回上层
		je EnterToMain
		jmp EnterToGame ;转移到游戏界面
		jmp EnterInMenuReturn

		;3号界面转移（结算界面）
	EnterInResult:
		cmp SelectMenu,0
		je EnterToMain
		jmp EnterToEndGame

		;转到初始界面
	EnterToMain:
		mov WhichMenu,0
		mov SelectMenu,0
		jmp EnterInMenuReturn
	
		;转到模式选择
	EnterToMode:
		mov WhichMenu,1
		jmp EnterInMenuReturn

		;转到游戏界面
		;转移前进行模式赋值
	EnterToGame:
		mov eax,SelectMenu
		and eax,1;取SelectMenu最后一位
		mov GameMode,eax;0，2变成0，对应闯关模式，1,3变成1，对应挑战模式
		mov eax,SelectMenu
		sar eax,1;算数右移，00b和01b都会变成00b，对应单人模式,10b和11b都会变成11b，对应双人模式
		mov IsDoublePlayer,eax	
		mov WhichMenu,2
		call ResetField
		jmp EnterInMenuReturn

		;退出游戏
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

;退出游戏
EnterToEndGame:
	push 0
	call PostQuitMessage
	push 1
	push hMainWnd
	call KillTimer
	pop eax
	ret

;esc键响应
EscapeInMenu proc
		mov SelectMenu,0
		mov WhichMenu,0
		ret
EscapeInMenu endp

;重置数据
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

;初始化
NewRound:
		mov WaitingTime,-1
		;玩家1
		mov [YourRole],1	
		mov [YourRole+4],128;坦克左移到边界,初始位置横坐标
		mov [YourRole+8],448;坦克初始位置纵坐标
		mov [YourRole+12],3 ;坦克初始朝向，0向右，顺时针增加0-3
		mov [YourRole+16],7 ;子弹类型
		;玩家2
		mov [YourRole+32],2
		mov [YourRole+36],320
		mov [YourRole+40],448
		mov [YourRole+44],3
		mov [YourRole+48],0
		;判断是否双人，双人就把玩家2标志清0，则后面绘制的时候就不会对玩家2相关数据进行绘制
		cmp IsDoublePlayer,0
		jne InitEnemyLife
		mov [YourRole+32],0
		mov [YourLife+4],0

		;初始化
	InitEnemyLife:
		mov eax,[Round]
		mov ebx,12
		mul ebx
		mov ebx,eax	

		mov eax,[RoundEnemy+ebx] ;根据关卡初始化三种怪的总生命
		mov [EnemyLife],eax
		mov eax,[RoundEnemy+ebx+4]
		mov [EnemyLife+4],eax
		mov eax,[RoundEnemy+ebx+8]
		mov [EnemyLife+8],eax
		
		;清空怪和子弹
		mov ecx,10	
		mov esi,offset Enemy
	RemoveEnemy:
		mov DWORD ptr [esi],0	;标记怪为0不存在
		mov DWORD ptr [esi+16],0;标记子弹为0不存在
		add esi,32				;换下一个
		loop RemoveEnemy
		
		;初始化地图
		mov eax,[Round]
		mov ebx,225*4
		mul ebx
		mov ebx,eax	
		mov ecx,225	;对应225个地图块，循环225次，把RoundMap中Round对应的地图放到Map中
	SetMap:
		mov eax,[RoundMap+ebx+ecx*4-4]
		mov [Map+ecx*4-4],eax
		loop SetMap

		ret

;绘制地面
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
		
		;判断地图矩阵中的值属于哪一个，然后去对应的函数进行绘制
		test [Map+ecx*4-4],4 
		jnz DrawWallHalf
		cmp [Map+ecx*4-4],3	;墙体
		je DrawWallBlock
		cmp [Map+ecx*4-4],11;厚墙体
		je DrawWallMetal
		cmp [Map+ecx*4-4],8	;北理工基地
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
;绘制怪和子弹，根据YourRole的参数来选择对应的位图来实现绘制
		mov esi,offset YourRole
		mov ecx,12	;最多的怪数目
	DrawEnemyAndBulletLoop:
		push esi
		mov eax,0
		cmp [esi],eax;怪是否为0
		je GoToDrawBulletIThink
		push ecx
		mov eax,[esi];第几种怪
		inc eax
		sal eax,3
		;找到位图中的地址
		add eax,[esi+12]
		mov ebx,[esi+4]
		add ebx,80
		
		push [esi+8]
		push ebx
		push eax
		;将位置、初始朝向都压入栈 使用drawspirit来绘制
		call DrawSpirit
		pop ecx

	GoToDrawBulletIThink:
		mov esi,[esp];应该还是esi
		add esi,16	;跳转到子弹的描述部分
		mov eax,0
		cmp [esi],eax	;是否为0（不存在）
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
		add esi,32	;跳转到下一个物体进行绘制
		loop DrawEnemyAndBulletLoop
		ret


DrawSideBar:
;画边框里的内容
		mov ecx,IsDoublePlayer
		inc ecx
		mov eax,64
		mov ebx,07h
		mov esi,offset YourLife ;生命值
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
		
		;命的数字
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
	;绘制得分板
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
		
		;更新得分板
		mov esi,[esp]			;代表两个玩家
		mov eax,[Score+4*esi]	;两个玩家对应的分数
		mov esi,offset ScoreText;esi对应分数板字符串
		add esi,5
		mov ecx,6
		mov ebx,10
	DrawSideBarGetScoreText:
	;将score中的数字转化为字符后存在对应的scoretest中
		mov edx,0
		div ebx
		add edx,30h
		mov [esi],dl
		dec esi
		loop DrawSideBarGetScoreText
	
		;绘制分数板
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

;TODO根据按下的按键修改状态。修改后交由PaintMessage里的DrawUI刷新
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
		add edx,24;位置矩阵的4个坐标
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
    ; 函数体
    ; 这里可以使用参数，例如 mov eax, arg1
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