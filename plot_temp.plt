# ---------------- Paramètres ---------------- 
set encoding utf8
Nx = 20
Ny = 14

# Seuils d'alerte pour les températures extrêmes
temp_froid_extreme = -100  # Température très basse (alerte froid)
temp_chaud_extreme = 200   # Température très haute (alerte chaud)

# Utilisation de 'wxt' ou 'qt' si possible pour plus de stabilité, sinon 'windows'
set terminal windows
set palette defined (0 "blue", 0.25 "cyan", 0.5 "green", 0.75 "yellow", 1 "red")
set cbrange [-360:300]
set view map
set size square
set xrange [0:Nx-1]
set yrange [0:Ny-1]
set pm3d map
set pm3d corners2color c1

# ---------------- Lecture des données ---------------- 
array T[Nx*Ny]
array T_initial[Nx*Ny]  # Sauvegarde de l'état initial
file = "Tmatrix.txt"

# Variables pour suivre le point sélectionné
selected_x = -1
selected_y = -1
point_selected = 0
alerte_active = 0  # 0: pas d'alerte, 1: froid extrême, 2: chaud extrême

print "Chargement des donnees... Patientez."
do for [y=0:Ny-1] {
    line = system(sprintf("powershell -Command \"(Get-Content '%s')[%d]\"", file, y))
    do for [x=0:Nx-1] {
        T[1 + x + y*Nx] = real(word(line, x+1))
        T_initial[1 + x + y*Nx] = T[1 + x + y*Nx]  # Sauvegarde initiale
    }
}

getT(px, py) = T[1 + int(px) + int(py)*Nx]

# ---------------- Définition des boutons ---------------- 
# Bouton 1 : Refroidir (en bas à gauche)
btn1_x1 = 0
btn1_x2 = 4
btn1_y1 = -2.5
btn1_y2 = -1.5

# Bouton 2 : Chauffer (au milieu gauche)
btn2_x1 = 4.5
btn2_x2 = 8.5
btn2_y1 = -2.5
btn2_y2 = -1.5

# Bouton 3 : Réinitialiser (au milieu droit)
btn3_x1 = 9
btn3_x2 = 13
btn3_y1 = -2.5
btn3_y2 = -1.5

# Bouton 4 : Refroidir -5°C (en bas, deuxième rangée gauche)
btn4_x1 = 0
btn4_x2 = 4
btn4_y1 = -3.5
btn4_y2 = -2.7

# Bouton 5 : Chauffer +5°C (en bas, deuxième rangée milieu)
btn5_x1 = 4.5
btn5_x2 = 8.5
btn5_y1 = -3.5
btn5_y2 = -2.7

# Bouton 6 : Visualiser tout (en bas, deuxième rangée droite)
btn6_x1 = 9
btn6_x2 = 13
btn6_y1 = -3.5
btn6_y2 = -2.7

# Bouton 7 : Mode Nuit/Jour (à droite)
btn7_x1 = 14
btn7_x2 = 18
btn7_y1 = -2.5
btn7_y2 = -1.5

# Variables pour visualisation globale
show_all_temps = 0
mode_nuit = 0  # 0 = jour, 1 = nuit

# Ajustement de la plage Y pour afficher les boutons
set yrange [-4:Ny-1]

# Dessiner les boutons avec style amélioré
# Bouton Refroidir -20°C (bleu foncé avec bordure)
set object 1 rect from btn1_x1,btn1_y1 to btn1_x2,btn1_y2 fc rgb "#0066cc" fillstyle solid 0.7 border lc rgb "#003366" lw 3
set label 10 "❄ REFROIDIR\n-20°C" at (btn1_x1+btn1_x2)/2, (btn1_y1+btn1_y2)/2 center tc rgb "white" font ",10"

# Bouton Chauffer +20°C (rouge foncé avec bordure)
set object 2 rect from btn2_x1,btn2_y1 to btn2_x2,btn2_y2 fc rgb "#cc0000" fillstyle solid 0.7 border lc rgb "#660000" lw 3
set label 11 "🔥 CHAUFFER\n+20°C" at (btn2_x1+btn2_x2)/2, (btn2_y1+btn2_y2)/2 center tc rgb "white" font ",10"

# Bouton Réinitialiser (gris foncé avec bordure)
set object 3 rect from btn3_x1,btn3_y1 to btn3_x2,btn3_y2 fc rgb "#666666" fillstyle solid 0.7 border lc rgb "#333333" lw 3
set label 12 "↻ RESET" at (btn3_x1+btn3_x2)/2, (btn3_y1+btn3_y2)/2 center tc rgb "white" font ",10"

# Bouton Refroidir -5°C (bleu clair avec bordure)
set object 4 rect from btn4_x1,btn4_y1 to btn4_x2,btn4_y2 fc rgb "#66b3ff" fillstyle solid 0.7 border lc rgb "#3399ff" lw 2
set label 13 "❄ -5°C" at (btn4_x1+btn4_x2)/2, (btn4_y1+btn4_y2)/2 center tc rgb "white" font ",9"

# Bouton Chauffer +5°C (orange avec bordure)
set object 5 rect from btn5_x1,btn5_y1 to btn5_x2,btn5_y2 fc rgb "#ff9933" fillstyle solid 0.7 border lc rgb "#ff6600" lw 2
set label 14 "🔥 +5°C" at (btn5_x1+btn5_x2)/2, (btn5_y1+btn5_y2)/2 center tc rgb "white" font ",9"

# Bouton Visualiser tout (vert avec bordure)
set object 6 rect from btn6_x1,btn6_y1 to btn6_x2,btn6_y2 fc rgb "#009900" fillstyle solid 0.7 border lc rgb "#006600" lw 2
set label 15 "👁 VOIR TOUT" at (btn6_x1+btn6_x2)/2, (btn6_y1+btn6_y2)/2 center tc rgb "white" font ",9"

# Bouton Mode Nuit/Jour (jaune/violet avec bordure)
set object 7 rect from btn7_x1,btn7_y1 to btn7_x2,btn7_y2 fc rgb "#ffcc00" fillstyle solid 0.7 border lc rgb "#cc9900" lw 3
set label 16 "☀ MODE JOUR" at (btn7_x1+btn7_x2)/2, (btn7_y1+btn7_y2)/2 center tc rgb "black" font ",9"

# Zone d'alerte visuelle (désactivée par défaut)
set object 10 rect from -0.5,-4.5 to Nx-0.5,-0.5 fc rgb "white" fillstyle empty border lc rgb "white" lw 0

# ---------------- Tracé Initial ---------------- 
splot file matrix with image notitle

# ---------------- Interaction (SÉCURISÉE) ---------------- 
print "-------------------------------------------------------"
print " PROGRAMME ACTIF "
print " - Cliquez sur un POINT pour le selectionner"
print " "
print " BOUTONS DE CONTROLE (avec style ameliore):"
print "   Rangee 1:"
print "     ❄ REFROIDIR -20°C : Refroidissement rapide (bleu fonce)"
print "     🔥 CHAUFFER +20°C  : Chauffage rapide (rouge fonce)"
print "     ↻ RESET            : Revenir a l'etat initial (gris)"
print "     ☀ MODE JOUR        : Basculer Jour/Nuit (jaune/violet)"
print "   Rangee 2:"
print "     ❄ -5°C             : Ajustement froid precis (bleu clair)"
print "     🔥 +5°C             : Ajustement chaud precis (orange)"
print "     👁 VOIR TOUT       : Toggle manuel affichage (vert)"
print " "
print " MODE NUIT/JOUR:"
print "   - MODE JOUR (par defaut) : Palette classique (bleu -> rouge)"
print "   - MODE NUIT : Palette sombre (bleu fonce -> bleu clair)"
print "   - Textes en BLANC (jour) ou CYAN (nuit) pour meilleure visibilite"
print "   - Cliquez sur le bouton pour basculer entre les modes"
print " "
print " AFFICHAGE AUTOMATIQUE DES TEMPERATURES:"
print "   - DES QUE vous chauffez/refroidissez un point,"
print "   - TOUTES les temperatures apparaissent EN TEMPS REEL"
print "   - Vous voyez TOUS les changements instantanement"
print " "
print " TEXTES D'ALERTE AMELIORES:"
print "   - Police Arial avec taille 16 (alertes) et 12 (messages)"
print "   - Textes encadres (boxed) pour meilleure visibilite"
print "   - Compteur de temps bien visible pendant l'alarme"
print " "
print " ALERTES SONORES ET VISUELLES (30 SECONDES CONTINUES):"
print sprintf(" - Temperature <= %.0f°C :", temp_froid_extreme)
print "   * MESSAGE VOCAL: 'Attention ! Temperature de congelation critique !'"
print "   * Sons graves + Compteur de temps"
print sprintf(" - Temperature >= %.0f°C :", temp_chaud_extreme)
print "   * MESSAGE VOCAL: 'Vite, a l'aide ! Il y a un incendie !'"
print "   * Sirene ambulance (800Hz/600Hz) + Compteur de temps"
print " "
print " - Pour arreter l'alarme: Appuyez sur Ctrl+C dans le terminal"
print " - Pour fermer : Fermez la fenetre graphique"
print "-------------------------------------------------------"

while (1) {
    # On attend UNIQUEMENT un événement souris
    pause mouse any "Cliquez sur un point ou un bouton"
    
    # On vérifie si c'est un clic gauche (Bouton 1)
    if (MOUSE_BUTTON == 1) {
        posX = MOUSE_X
        posY = MOUSE_Y
        
        # Vérifier si clic sur bouton REFROIDIR
        if (posX >= btn1_x1 && posX <= btn1_x2 && posY >= btn1_y1 && posY <= btn1_y2) { \
            if (point_selected == 1) { \
                print sprintf(">>> REFROIDISSEMENT du point X:%d Y:%d de 20°C", selected_x, selected_y); \
                idx = 1 + selected_x + selected_y*Nx; \
                T[idx] = T[idx] - 20; \
                val = T[idx]; \
                set print "temp_matrix.txt"; \
                do for [y=0:Ny-1] { \
                    line_str = ""; \
                    do for [x=0:Nx-1] { \
                        if (x > 0) { line_str = line_str . " " }; \
                        line_str = line_str . sprintf("%.2f", T[1 + x + y*Nx]); \
                    }; \
                    print line_str; \
                }; \
                set print; \
                if (val <= temp_froid_extreme) { \
                    alerte_active = 1; \
                    print "!!! ALERTE: TEMPERATURE TRES BASSE !!!"; \
                    print ">>> ALARME CONTINUE 30 SECONDES - Sons graves + Message vocal"; \
                    print ">>> MESSAGE VOCAL: 'Attention ! Temperature de congelation critique !'"; \
                    dummy = system("powershell -c \"Add-Type -AssemblyName System.Speech; $synth = New-Object System.Speech.Synthesis.SpeechSynthesizer; $synth.SelectVoiceByHints([System.Speech.Synthesis.VoiceGender]::Female, [System.Speech.Synthesis.VoiceAge]::Adult); $synth.Rate = 1; $synth.Speak('Attention! Température de congélation critique! Attention! Température de congélation critique!')\""); \
                    do for [blink=1:60] { \
                        temps_restant = 30 - int(blink/2); \
                        if (blink % 2 == 1) { \
                            set object 10 rect from -0.5,-4.5 to Nx-0.5,-0.5 fc rgb "blue" fillstyle solid 0.6 border lc rgb "blue" lw 10; \
                            set label 20 sprintf("!!! ALERTE FROID EXTREME !!! [%ds]", temps_restant) at Nx/2, -4 center tc rgb "white" font "Arial,16" front boxed; \
                        } else { \
                            set object 10 rect from -0.5,-4.5 to Nx-0.5,-0.5 fc rgb "cyan" fillstyle solid 0.2 border lc rgb "blue" lw 5; \
                            set label 20 sprintf("!!! ALERTE FROID EXTREME !!! [%ds]", temps_restant) at Nx/2, -4 center tc rgb "blue" font "Arial,14" front boxed; \
                        }; \
                        splot "temp_matrix.txt" matrix with image notitle; \
                        set label 1 sprintf("T = %.2f°C", val) at selected_x, selected_y front point pt 7 ps 2 lc rgb "white" font "Arial,10"; \
                        label_num = 100; \
                        do for [py=0:Ny-1] { \
                            do for [px=0:Nx-1] { \
                                temp_val = T[1 + px + py*Nx]; \
                                set label label_num sprintf("%.0f", temp_val) at px, py center tc rgb "white" font "Arial,6" front; \
                                label_num = label_num + 1; \
                            }; \
                        }; \
                        replot; \
                        dummy = system("powershell -c \"[console]::beep(300,250)\""); \
                    }; \
                    print ">>> ALARME TERMINEE (30 secondes ecoulees)"; \
                    set object 10 rect from -0.5,-4.5 to Nx-0.5,-0.5 fc rgb "blue" fillstyle solid 0.3 border lc rgb "blue" lw 6; \
                    set label 20 "TEMPERATURE STABLE EN ZONE EXTREME" at Nx/2, -4 center tc rgb "white" font "Arial,12" front boxed; \
                } else { \
                    alerte_active = 0; \
                    set object 10 rect from -0.5,-4.5 to Nx-0.5,-0.5 fc rgb "white" fillstyle empty border lc rgb "white" lw 0; \
                    unset label 20; \
                }; \
                splot "temp_matrix.txt" matrix with image notitle; \
                set label 1 sprintf("T = %.2f°C", val) at selected_x, selected_y front point pt 7 ps 2 lc rgb "white" font "Arial,10"; \
                label_num = 100; \
                do for [py=0:Ny-1] { \
                    do for [px=0:Nx-1] { \
                        temp_val = T[1 + px + py*Nx]; \
                        set label label_num sprintf("%.0f", temp_val) at px, py center tc rgb "white" font "Arial,6" front; \
                        label_num = label_num + 1; \
                    }; \
                }; \
                print sprintf("Nouvelle temperature: %.2f°C", val); \
                replot; \
            } else { \
                print ">>> Aucun point selectionne ! Cliquez d'abord sur un point de la carte."; \
            }; \
        }
        
        # Vérifier si clic sur bouton REFROIDIR -5°C
        if (posX >= btn4_x1 && posX <= btn4_x2 && posY >= btn4_y1 && posY <= btn4_y2) { \
            if (point_selected == 1) { \
                print sprintf(">>> REFROIDISSEMENT LEGER du point X:%d Y:%d de 5°C", selected_x, selected_y); \
                idx = 1 + selected_x + selected_y*Nx; \
                T[idx] = T[idx] - 5; \
                val = T[idx]; \
                set print "temp_matrix.txt"; \
                do for [y=0:Ny-1] { \
                    line_str = ""; \
                    do for [x=0:Nx-1] { \
                        if (x > 0) { line_str = line_str . " " }; \
                        line_str = line_str . sprintf("%.2f", T[1 + x + y*Nx]); \
                    }; \
                    print line_str; \
                }; \
                set print; \
                splot "temp_matrix.txt" matrix with image notitle; \
                set label 1 sprintf("T = %.2f°C", val) at selected_x, selected_y front point pt 7 ps 2 lc rgb "white" font "Arial,10"; \
                label_num = 100; \
                do for [py=0:Ny-1] { \
                    do for [px=0:Nx-1] { \
                        temp_val = T[1 + px + py*Nx]; \
                        set label label_num sprintf("%.0f", temp_val) at px, py center tc rgb "white" font "Arial,6" front; \
                        label_num = label_num + 1; \
                    }; \
                }; \
                print sprintf("Nouvelle temperature: %.2f°C", val); \
                replot; \
            } else { \
                print ">>> Aucun point selectionne ! Cliquez d'abord sur un point de la carte."; \
            }; \
        }
        
        # Vérifier si clic sur bouton CHAUFFER +5°C
        if (posX >= btn5_x1 && posX <= btn5_x2 && posY >= btn5_y1 && posY <= btn5_y2) { \
            if (point_selected == 1) { \
                print sprintf(">>> CHAUFFAGE LEGER du point X:%d Y:%d de 5°C", selected_x, selected_y); \
                idx = 1 + selected_x + selected_y*Nx; \
                T[idx] = T[idx] + 5; \
                val = T[idx]; \
                set print "temp_matrix.txt"; \
                do for [y=0:Ny-1] { \
                    line_str = ""; \
                    do for [x=0:Nx-1] { \
                        if (x > 0) { line_str = line_str . " " }; \
                        line_str = line_str . sprintf("%.2f", T[1 + x + y*Nx]); \
                    }; \
                    print line_str; \
                }; \
                set print; \
                splot "temp_matrix.txt" matrix with image notitle; \
                set label 1 sprintf("T = %.2f°C", val) at selected_x, selected_y front point pt 7 ps 2 lc rgb "white" font "Arial,10"; \
                label_num = 100; \
                do for [py=0:Ny-1] { \
                    do for [px=0:Nx-1] { \
                        temp_val = T[1 + px + py*Nx]; \
                        set label label_num sprintf("%.0f", temp_val) at px, py center tc rgb "white" font "Arial,6" front; \
                        label_num = label_num + 1; \
                    }; \
                }; \
                print sprintf("Nouvelle temperature: %.2f°C", val); \
                replot; \
            } else { \
                print ">>> Aucun point selectionne ! Cliquez d'abord sur un point de la carte."; \
            }; \
        }
        
        # Vérifier si clic sur bouton VISUALISER TOUT
        if (posX >= btn6_x1 && posX <= btn6_x2 && posY >= btn6_y1 && posY <= btn6_y2) { \
            if (show_all_temps == 0) { \
                show_all_temps = 1; \
                print ">>> MODE VISUALISATION GLOBALE ACTIVE"; \
                print ">>> Affichage des temperatures de TOUS les points..."; \
                set object 6 rect from btn6_x1,btn6_y1 to btn6_x2,btn6_y2 fc rgb "#00cc00" fillstyle solid 0.9 border lc rgb "#009900" lw 3; \
                set label 15 "👁 ACTIF" at (btn6_x1+btn6_x2)/2, (btn6_y1+btn6_y2)/2 center tc rgb "white" font ",10"; \
                label_num = 100; \
                do for [py=0:Ny-1] { \
                    do for [px=0:Nx-1] { \
                        temp_val = T[1 + px + py*Nx]; \
                        set label label_num sprintf("%.0f", temp_val) at px, py center tc rgb "white" font "Arial,6" front; \
                        label_num = label_num + 1; \
                    }; \
                }; \
                replot; \
            } else { \
                show_all_temps = 0; \
                print ">>> MODE VISUALISATION GLOBALE DESACTIVE"; \
                set object 6 rect from btn6_x1,btn6_y1 to btn6_x2,btn6_y2 fc rgb "#009900" fillstyle solid 0.7 border lc rgb "#006600" lw 2; \
                set label 15 "👁 VOIR TOUT" at (btn6_x1+btn6_x2)/2, (btn6_y1+btn6_y2)/2 center tc rgb "white" font ",9"; \
                do for [i=100:100+Nx*Ny] { \
                    unset label i; \
                }; \
                replot; \
            }; \
        }
        
        # Vérifier si clic sur bouton MODE NUIT/JOUR
        if (posX >= btn7_x1 && posX <= btn7_x2 && posY >= btn7_y1 && posY <= btn7_y2) { \
            if (mode_nuit == 0) { \
                mode_nuit = 1; \
                print ">>> MODE NUIT ACTIVE - Palette sombre"; \
                set palette defined (0 "#000033", 0.25 "#000066", 0.5 "#003366", 0.75 "#006699", 1 "#0099cc"); \
                set object 7 rect from btn7_x1,btn7_y1 to btn7_x2,btn7_y2 fc rgb "#1a0066" fillstyle solid 0.9 border lc rgb "#0d0033" lw 3; \
                set label 16 "🌙 MODE NUIT" at (btn7_x1+btn7_x2)/2, (btn7_y1+btn7_y2)/2 center tc rgb "white" font ",9"; \
                splot "temp_matrix.txt" matrix with image notitle; \
                label_num = 100; \
                do for [py=0:Ny-1] { \
                    do for [px=0:Nx-1] { \
                        temp_val = T[1 + px + py*Nx]; \
                        set label label_num sprintf("%.0f", temp_val) at px, py center tc rgb "cyan" font "Arial,6" front; \
                        label_num = label_num + 1; \
                    }; \
                }; \
                if (point_selected == 1) { \
                    val = getT(selected_x, selected_y); \
                    set label 1 sprintf("T = %.2f°C", val) at selected_x, selected_y front point pt 7 ps 2 lc rgb "cyan" font "Arial,10"; \
                }; \
                replot; \
            } else { \
                mode_nuit = 0; \
                print ">>> MODE JOUR ACTIVE - Palette claire"; \
                set palette defined (0 "blue", 0.25 "cyan", 0.5 "green", 0.75 "yellow", 1 "red"); \
                set object 7 rect from btn7_x1,btn7_y1 to btn7_x2,btn7_y2 fc rgb "#ffcc00" fillstyle solid 0.7 border lc rgb "#cc9900" lw 3; \
                set label 16 "☀ MODE JOUR" at (btn7_x1+btn7_x2)/2, (btn7_y1+btn7_y2)/2 center tc rgb "black" font ",9"; \
                splot "temp_matrix.txt" matrix with image notitle; \
                label_num = 100; \
                do for [py=0:Ny-1] { \
                    do for [px=0:Nx-1] { \
                        temp_val = T[1 + px + py*Nx]; \
                        set label label_num sprintf("%.0f", temp_val) at px, py center tc rgb "white" font "Arial,6" front; \
                        label_num = label_num + 1; \
                    }; \
                }; \
                if (point_selected == 1) { \
                    val = getT(selected_x, selected_y); \
                    set label 1 sprintf("T = %.2f°C", val) at selected_x, selected_y front point pt 7 ps 2 lc rgb "white" font "Arial,10"; \
                }; \
                replot; \
            }; \
        }
        
        # Vérifier si clic sur bouton CHAUFFER
        if (posX >= btn2_x1 && posX <= btn2_x2 && posY >= btn2_y1 && posY <= btn2_y2) { \
            if (point_selected == 1) { \
                print sprintf(">>> CHAUFFAGE du point X:%d Y:%d de 20°C", selected_x, selected_y); \
                idx = 1 + selected_x + selected_y*Nx; \
                T[idx] = T[idx] + 20; \
                val = T[idx]; \
                set print "temp_matrix.txt"; \
                do for [y=0:Ny-1] { \
                    line_str = ""; \
                    do for [x=0:Nx-1] { \
                        if (x > 0) { line_str = line_str . " " }; \
                        line_str = line_str . sprintf("%.2f", T[1 + x + y*Nx]); \
                    }; \
                    print line_str; \
                }; \
                set print; \
                if (val >= temp_chaud_extreme) { \
                    alerte_active = 2; \
                    print "!!! ALERTE: TEMPERATURE TRES HAUTE !!!"; \
                    print ">>> ALARME CONTINUE 30 SECONDES - Sirene AMBULANCE + Message vocal"; \
                    print ">>> MESSAGE VOCAL: 'Vite, a l'aide ! Il y a un incendie !'"; \
                    dummy = system("powershell -c \"Add-Type -AssemblyName System.Speech; $synth = New-Object System.Speech.Synthesis.SpeechSynthesizer; $synth.SelectVoiceByHints([System.Speech.Synthesis.VoiceGender]::Female, [System.Speech.Synthesis.VoiceAge]::Adult); $synth.Rate = 1; $synth.Speak('Vite, à l''aide! Il y a un incendie! Vite, à l''aide! Il y a un incendie!')\""); \
                    do for [blink=1:60] { \
                        temps_restant = 30 - int(blink/2); \
                        if (blink % 2 == 1) { \
                            set object 10 rect from -0.5,-4.5 to Nx-0.5,-0.5 fc rgb "red" fillstyle solid 0.6 border lc rgb "red" lw 10; \
                            set label 20 sprintf("!!! ALERTE COMBUSTION !!! [%ds]", temps_restant) at Nx/2, -4 center tc rgb "white" font ",14" front; \
                            dummy = system("powershell -c \"[console]::beep(800,150); [console]::beep(600,150)\""); \
                        } else { \
                            set object 10 rect from -0.5,-4.5 to Nx-0.5,-0.5 fc rgb "orange" fillstyle solid 0.2 border lc rgb "red" lw 5; \
                            set label 20 sprintf("!!! ALERTE COMBUSTION !!! [%ds]", temps_restant) at Nx/2, -4 center tc rgb "red" font ",12" front; \
                            dummy = system("powershell -c \"[console]::beep(600,150); [console]::beep(800,150)\""); \
                        }; \
                        splot "temp_matrix.txt" matrix with image notitle; \
                        set label 1 sprintf("T = %.2f°C", val) at selected_x, selected_y front point pt 7 ps 1.5 lc rgb "white"; \
                        replot; \
                    }; \
                    print ">>> ALARME TERMINEE (30 secondes ecoulees)"; \
                    set object 10 rect from -0.5,-4.5 to Nx-0.5,-0.5 fc rgb "red" fillstyle solid 0.3 border lc rgb "red" lw 6; \
                    set label 20 "RISQUE DE COMBUSTION - TEMPERATURE EXTREME" at Nx/2, -4 center tc rgb "white" font ",10" front; \
                } else { \
                    alerte_active = 0; \
                    set object 10 rect from -0.5,-3.5 to Nx-0.5,-0.5 fc rgb "white" fillstyle empty border lc rgb "white" lw 0; \
                    unset label 20; \
                }; \
                splot "temp_matrix.txt" matrix with image notitle; \
                set label 1 sprintf("T = %.2f°C", val) at selected_x, selected_y front point pt 7 ps 1.5 lc rgb "white"; \
                print sprintf("Nouvelle temperature: %.2f°C", val); \
                replot; \
            } else { \
                print ">>> Aucun point selectionne ! Cliquez d'abord sur un point de la carte."; \
            }; \
        }
        
        # Vérifier si clic sur bouton RÉINITIALISER
        if (posX >= btn3_x1 && posX <= btn3_x2 && posY >= btn3_y1 && posY <= btn3_y2) { \
            print ">>> REINITIALISATION a l'etat initial"; \
            do for [i=1:Nx*Ny] { \
                T[i] = T_initial[i]; \
            }; \
            point_selected = 0; \
            selected_x = -1; \
            selected_y = -1; \
            alerte_active = 0; \
            unset label 1; \
            unset label 20; \
            set object 10 rect from -0.5,-4.5 to Nx-0.5,-0.5 fc rgb "white" fillstyle empty border lc rgb "white" lw 0; \
            set print "temp_matrix.txt"; \
            do for [y=0:Ny-1] { \
                line_str = ""; \
                do for [x=0:Nx-1] { \
                    if (x > 0) { line_str = line_str . " " }; \
                    line_str = line_str . sprintf("%.2f", T[1 + x + y*Nx]); \
                }; \
                print line_str; \
            }; \
            set print; \
            splot "temp_matrix.txt" matrix with image notitle; \
        }
        
        # Clic sur la carte pour sélectionner un point (si pas sur un bouton)
        if (!(posX >= btn1_x1 && posX <= btn1_x2 && posY >= btn1_y1 && posY <= btn1_y2) && \
            !(posX >= btn2_x1 && posX <= btn2_x2 && posY >= btn2_y1 && posY <= btn2_y2) && \
            !(posX >= btn3_x1 && posX <= btn3_x2 && posY >= btn3_y1 && posY <= btn3_y2) && \
            !(posX >= btn4_x1 && posX <= btn4_x2 && posY >= btn4_y1 && posY <= btn4_y2) && \
            !(posX >= btn5_x1 && posX <= btn5_x2 && posY >= btn5_y1 && posY <= btn5_y2) && \
            !(posX >= btn6_x1 && posX <= btn6_x2 && posY >= btn6_y1 && posY <= btn6_y2)) { \
            posX_int = int(posX); \
            posY_int = int(posY); \
            if (posX_int >= 0 && posX_int < Nx && posY_int >= 0 && posY_int < Ny) { \
                selected_x = posX_int; \
                selected_y = posY_int; \
                point_selected = 1; \
                val = getT(posX_int, posY_int); \
                set label 1 sprintf("T = %.2f°C", val) at posX, posY front point pt 7 ps 1.5 lc rgb "white"; \
                print sprintf("Point selectionne -> X:%d Y:%d -> Temp:%.2f°C", posX_int, posY_int, val); \
                print "Vous pouvez maintenant cliquer sur REFROIDIR ou CHAUFFER"; \
                replot; \
            }; \
        }
    }
}



