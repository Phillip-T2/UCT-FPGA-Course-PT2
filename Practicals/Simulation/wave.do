onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ADXL345_TB/ipClk
add wave -noupdate /ADXL345_TB/ipReset
add wave -noupdate /ADXL345_TB/opX
add wave -noupdate /ADXL345_TB/opY
add wave -noupdate /ADXL345_TB/opZ
add wave -noupdate /ADXL345_TB/opnCS
add wave -noupdate /ADXL345_TB/opSClk
add wave -noupdate /ADXL345_TB/opSDI
add wave -noupdate /ADXL345_TB/ipSDO
add wave -noupdate /ADXL345_TB/DataIn
add wave -noupdate /ADXL345_TB/DataOut
add wave -noupdate /ADXL345_TB/n
add wave -noupdate /ADXL345_TB/Accelerator/State
add wave -noupdate -format Analog-Step -height 50 -max 32.0 -radix unsigned /ADXL345_TB/Accelerator/Count
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 255
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {6983200 ps} {101765207 ps}
