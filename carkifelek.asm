.model small
.stack 100h

.data
    s0 db '0 (IFLAS)$'
    s1 db '   250   $'
    s2 db '   500   $'
    s3 db '   100   $'
    s4 db '   750   $'
    s5 db '  1000   $'
    s6 db '    50   $'
    s7 db '   400   $'

    ptrs dw offset s0, offset s1, offset s2, offset s3, offset s4, offset s5, offset s6, offset s7
    coords db 35,5, 50,8, 55,12, 50,16, 35,19, 20,16, 15,12, 20,8
    
    arrow db '    V    $'
    msg_win db 'Oyun Bitti. Kazanciniz: $'
    speed_msg db 'HIZ: $'
    
    ; 50-100 arasi hýz deðeri
    hiz_degeri dw 0

.code
main proc
    mov ax, @data
    mov ds, ax

    call clear_screen
    call hide_cursor

    ; --- OYUN BAÞI RASTGELE HIZ SEÇÝMÝ (50-100) ---
    mov ah, 00h
    int 1Ah             
    mov ax, dx
    xor dx, dx
    mov bx, 51          
    div bx              
    add dx, 50          
    mov hiz_degeri, dx

    ; Ekrana Sabit Oku Çiz
    mov ah, 02h
    mov bh, 0
    mov dl, 35
    mov dh, 3
    int 10h
    mov ah, 09h
    lea dx, arrow
    int 21h

    ; Hýz bilgisini ekrana 1 kez yaz (Performans için döngü dýþý)
    call print_speed

game_loop:
    ; Çarký Eski Düzen (Düz) Çiz
    call draw_wheel

    ; Klavye Kontrolü (Space dinleme)
    mov ah, 01h
    int 16h
    jz continue_spinning 
    
    mov ah, 00h
    int 16h
    cmp al, 20h          
    je end_game          

continue_spinning:
    call apply_ultra_fast_delay
    call rotate_ptrs
    jmp game_loop

end_game:
    call show_cursor

    ; Oyun bitiþ ekraný
    mov ah, 02h
    mov bh, 0
    mov dl, 0
    mov dh, 22
    int 10h

    mov ah, 09h
    lea dx, msg_win
    int 21h

    ; Kazancý yaz
    mov ah, 09h
    mov dx, ptrs[0]      
    int 21h

    mov ax, 4C00h
    int 21h
main endp

; --------------------------------------------------
; Çark Çizim Prosedürü (Eski Düzene Dönüldü)
; --------------------------------------------------
draw_wheel proc
    push ax
    push bx
    push cx
    push dx
    push si
    
    mov cx, 8
    mov si, 0        ; Yeniden 0. indeksten baþlýyoruz
    
draw_loop:
    mov ah, 02h
    mov bh, 0
    mov dl, coords[si]
    mov dh, coords[si+1]
    int 10h
    
    mov ah, 09h
    mov dx, ptrs[si]
    int 21h
    
    add si, 2        ; Ýleriye doðru say
    loop draw_loop
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
draw_wheel endp

; --------------------------------------------------
; ÇOK HIZLI GECÝKME (Roket Modu)
; --------------------------------------------------
apply_ultra_fast_delay proc
    push ax
    push cx
    push dx
    
    ; Yeni Formül: Gecikmeyi çok daha fazla kýstým.
    mov ax, hiz_degeri
    mov bx, 40h         ; Hýz Çarpaný
    mul bx              
    
    mov dx, 2500h       ; Baz gecikme (Önceki 6500h idi, bekleme süresini 3'te 1'e düþürdük!)
    sub dx, ax          ; Max hýzda bekleme süresi 0C00h (yaklaþýk 3 milisaniye) olacak.
    
    mov cx, 0000h       
    mov ah, 86h         
    int 15h
    
    pop dx
    pop cx
    pop ax
    ret
apply_ultra_fast_delay endp

; --------------------------------------------------
; Hýzý Ekrana Yazdýrma
; --------------------------------------------------
print_speed proc
    push ax
    push bx
    push cx
    push dx

    mov ah, 02h
    mov bh, 0
    mov dh, 2
    mov dl, 65
    int 10h

    mov ah, 09h
    lea dx, speed_msg
    int 21h

    mov ax, hiz_degeri
    
    mov bl, 100
    div bl              
    push ax             
    add al, 30h
    mov dl, al
    mov ah, 02h
    int 21h
    pop ax
    
    mov al, ah          
    xor ah, ah
    mov bl, 10
    div bl              
    push ax
    add al, 30h
    mov dl, al
    mov ah, 02h
    int 21h
    pop ax
    
    mov al, ah
    add al, 30h
    mov dl, al
    mov ah, 02h
    int 21h

    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_speed endp

rotate_ptrs proc
    push ax
    push dx
    push si
    mov ax, ptrs[14]
    mov si, 14
rot_loop:
    mov dx, ptrs[si-2]
    mov ptrs[si], dx
    sub si, 2
    jg rot_loop
    mov ptrs[0], ax
    pop si
    pop dx
    pop ax
    ret
rotate_ptrs endp

clear_screen proc
    mov ah, 06h
    mov al, 0
    mov bh, 07h
    mov cx, 0
    mov dx, 184Fh
    int 10h
    ret
clear_screen endp

hide_cursor proc
    push ax
    push cx
    mov ah, 01h
    mov cx, 2607h       
    int 10h
    pop cx
    pop ax
    ret
hide_cursor endp

show_cursor proc
    push ax
    push cx
    mov ah, 01h
    mov cx, 0607h       
    int 10h
    pop cx
    pop ax
    ret
show_cursor endp

end main