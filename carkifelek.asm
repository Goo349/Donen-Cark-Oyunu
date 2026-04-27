.model small
.stack 100h

.data
    ; puanlar
    s0 db '  IFLAS  $'
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
    msg_win db 'Oyun Bitti! 5 Tur Tamamlandi. Toplam Puan: $'
    speed_msg db 'HIZ: $'
    
    ; arayuz mesajlari
    msg_round db 'TUR: $'
    msg_total db 'TOPLAM PUAN: $'
    msg_result db 'GELEN: $'
    msg_continue db 'Sonraki tur icin SPACE basiniz...$'
    
    ; 50-100 arasi hiz degeri
    hiz_degeri dw 0
    
    ; Oyun Degiskenleri
    current_round dw 1
    total_score dw 0

.code
main proc
    mov ax, @data
    mov ds, ax

round_start:
    call clear_screen
    call hide_cursor

    ; rastgele hiz 
    mov ah, 00h
    int 1Ah             
    mov ax, dx
    xor dx, dx
    mov bx, 51          
    div bx              
    add dx, 50          
    mov hiz_degeri, dx

    ; ok cizimi
    mov ah, 02h
    mov bh, 0
    mov dl, 35
    mov dh, 3
    int 10h
    mov ah, 09h
    lea dx, arrow
    int 21h

    ; hiz bilgisi ve Arayuz cizimi
    call print_speed
    call print_ui

game_loop:
    ; cark cizimi
    call draw_wheel

    ; space tusunu dinleme
    mov ah, 01h
    int 16h
    jz continue_spinning 
    
    mov ah, 00h
    int 16h
    cmp al, 20h          
    je end_spin          

continue_spinning:
    call apply_fast_delay
    call rotate_ptrs
    jmp game_loop

end_spin:
    ; puani hesapla ve arayuzu guncelle
    call calculate_score
    call print_ui

    ; gelen degeri ekranda ortada goster
    mov ah, 02h
    mov bh, 0
    mov dl, 30
    mov dh, 20
    int 10h
    mov ah, 09h
    lea dx, msg_result
    int 21h
    
    mov ah, 09h
    mov dx, ptrs[0]      
    int 21h

    ; 5 tur kontrolu
    inc current_round
    cmp current_round, 6
    je final_end

    ; Sonraki tur icin ekranda bilgi ver ve bekle
    mov ah, 02h
    mov bh, 0
    mov dl, 2
    mov dh, 23
    int 10h
    mov ah, 09h
    lea dx, msg_continue
    int 21h

wait_space:
    mov ah, 00h
    int 16h
    cmp al, 20h
    jne wait_space
    
    jmp round_start ; diger tura basla

final_end:
    call clear_screen
    call show_cursor

    ; oyun bitti ekrani
    mov ah, 02h
    mov bh, 0
    mov dl, 2
    mov dh, 12
    int 10h

    mov ah, 09h
    lea dx, msg_win
    int 21h

    ; kazanci yaz
    mov ax, total_score
    call print_number

    mov ax, 4C00h
    int 21h
main endp

; cark cizimi
draw_wheel proc
    push ax
    push bx
    push cx
    push dx
    push si
    
    mov cx, 8
    mov si, 0      
    
draw_loop:
    mov ah, 02h
    mov bh, 0
    mov dl, coords[si]
    mov dh, coords[si+1]
    int 10h
    
    mov ah, 09h
    mov dx, ptrs[si]
    int 21h
    
    add si, 2       
    loop draw_loop
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
draw_wheel endp

; gecikme azaltma
apply_fast_delay proc
    push ax
    push cx
    push dx
    
    mov ax, hiz_degeri
    mov bx, 40h         
    mul bx              
    
    mov dx, 2500h       
    sub dx, ax          
    
    mov cx, 0000h       
    mov ah, 86h         
    int 15h
    
    pop dx
    pop cx
    pop ax
    ret
apply_fast_delay endp

; hizi ekrana yazdirma 
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


; tur ve toplam puan arayuzu cizdirme

print_ui proc
    push ax
    push bx
    push dx
    
    ; TUR yazisi
    mov ah, 02h
    mov bh, 0
    mov dl, 2
    mov dh, 2
    int 10h
    mov ah, 09h
    lea dx, msg_round
    int 21h
    
    mov ax, current_round
    add al, 30h
    mov dl, al
    mov ah, 02h
    int 21h
    
    ; TOPLAM PUAN yazisi
    mov ah, 02h
    mov bh, 0
    mov dl, 2
    mov dh, 22
    int 10h
    mov ah, 09h
    lea dx, msg_total
    int 21h
    
    ; toplam puani ekrana yaz
    mov ax, total_score
    call print_number
    
    pop dx
    pop bx
    pop ax
    ret
print_ui endp


; puan hesaplama

calculate_score proc
    push ax
    mov ax, ptrs[0]
    
    cmp ax, offset s0
    je is_iflas
    cmp ax, offset s1
    je add_250
    cmp ax, offset s2
    je add_500
    cmp ax, offset s3
    je add_100
    cmp ax, offset s4
    je add_750
    cmp ax, offset s5
    je add_1000
    cmp ax, offset s6
    je add_50
    cmp ax, offset s7
    je add_400
    jmp done_calc

is_iflas:
    mov total_score, 0      
    jmp done_calc
add_250:
    add total_score, 250
    jmp done_calc
add_500:
    add total_score, 500
    jmp done_calc
add_100:
    add total_score, 100
    jmp done_calc
add_750:
    add total_score, 750
    jmp done_calc
add_1000:
    add total_score, 1000
    jmp done_calc
add_50:
    add total_score, 50
    jmp done_calc
add_400:
    add total_score, 400
    jmp done_calc

done_calc:
    pop ax
    ret
calculate_score endp


; AX register'indaki sayiyi ekrana yazdir

print_number proc
    push ax
    push bx
    push cx
    push dx
    
    cmp ax, 0
    jne start_div
    
    ; eger sayi tam 0 ise
    mov dl, '0'
    mov ah, 02h
    int 21h
    jmp end_print_num
    
start_div:
    mov cx, 0
    mov bx, 10
divide_loop:
    mov dx, 0
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne divide_loop
    
print_digits:
    pop dx
    add dl, 30h
    mov ah, 02h
    int 21h
    loop print_digits
    
end_print_num:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_number endp

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