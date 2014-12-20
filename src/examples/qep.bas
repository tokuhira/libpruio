/'* \file qep.bas
\brief Example: analyse QEP input (simulated by PWM outputs).

This file contains an example on how to use libpruio to analyse pulse
trains from a QEP sensor. The sensor signals can either come from a
real sensor. Or, to avoid the need of a real sensor, the signals can
get simulated by PWM output which is generated by this program.

Licence: GPLv3

Copyright 2014 by Thomas{ dOt ]Freiherr[ At ]gmx[ DoT }net


Compile by: `fbc -w all qep.bas`

\since 0.2.2
'/

' include libpruio
#INCLUDE ONCE "../pruio/pruio.bi"
' include the convenience macros for header pins
#INCLUDE ONCE "../pruio/pruio_pins.bi"

'* Default PMax value.
#DEFINE PMX 4095
'* The frequency for speed measurement.
#DEFINE VHz 25
'* The header pins to use for input (PWMSS-1).
DIM AS CONST UInt8 PINS(...) = {P8_12, P8_11, P8_16}

VAR io = NEW PruIo '*< Create a PruIo structure, wakeup subsystems.

WITH *io
  DO
    IF .Errr THEN ?"NEW failed: " & *.Errr : EXIT DO

    '' configure PWM-1 for symetric output duty 50% and phase shift 1 / 4
    .Pwm->ForceUpDown = 1
    .Pwm->AqCtl(0, 1, 1) = &b000000000110
    .Pwm->AqCtl(1, 1, 1) = &b011000000000

    DIM AS Float_t freq = 50., realfreq
    IF .Pwm->setValue(P9_14, freq, .0) THEN _
              ?"failed setting " & P9_14 & " (" & *.Errr & ")" : EXIT DO

    IF .Pwm->setValue(P9_16, freq, .25) THEN _
              ?"failed setting " & P9_16 & " (" & *.Errr & ")" : EXIT DO

    IF .Pwm->setValue(P9_42, .5, .00000005) THEN _
              ?"failed setting " & P9_42 & " (" & *.Errr & ")" : EXIT DO

    IF .Pwm->Value(P9_14, @realfreq, NULL) THEN _
                  ?"failed getting PWM value (" & *.Errr & ")" : EXIT DO

    DIM AS UInt32 pmax = PMX
    IF .Qep->config(PINS(0), pmax, VHz) THEN _ '      configure QEP pins
              ?"QEP pin configuration failed (" & *.Errr & ")" : EXIT DO

    IF .config(1, 0) THEN _ '                              configure PRU
      ?"config failed: " & *.Errr & " --> " & .DRam[0] : SLEEP : EXIT DO

    STATIC AS CONST ZSTRING PTR t(...) = {@"       A", @"   A & B", @"A, B & I"}
    DIM AS UInt32 posi, m = -1, p = 0
    DIM AS Float_t velo
    ?!"\n" & *t(p) & " input, " & freq & "Hz (" & realfreq & "), PMax=" & pmax
    DO '                           print current state (until keystroke)
      VAR k = ASC(INKEY()) '*< The key code.
      IF k THEN
        SELECT CASE AS CONST k '                react on user keystrokes
        CASE ASC("a"), ASC("A") : m = 0
        CASE ASC("b"), ASC("B") : m = 1
        CASE ASC("i"), ASC("I") : m = 2
        CASE ASC("0") : m = p : pmax = 0
        CASE ASC("1") : m = p : pmax = 1023
        CASE ASC("4") : m = p : pmax = 4095
        CASE ASC("5") : m = p : pmax = 511
        CASE ASC("8") : m = p : pmax = 8191
        CASE ASC("+") : m = 3 : .Pwm->AqCtl(0, 1, 1) = &b000000000110
        CASE ASC("-") : m = 3 : .Pwm->AqCtl(0, 1, 1) = &b000000001001
        CASE ASC("p"), ASC("P") : m = 3 : IF freq < 499995 THEN freq += 5 ELSE freq = 500000
        CASE ASC("m"), ASC("M") : m = 3 : IF freq >     20 THEN freq -= 5 ELSE freq = 25
        CASE ASC("*")           : m = 3 : IF freq < 250000 THEN freq *= 2 ELSE freq = 500000
        CASE ASC("/")           : m = 3 : IF freq >     50 THEN freq /= 2 ELSE freq = 25
        CASE 13 : m = 1 : freq = 50
          IF .Pwm->setValue(P9_14, freq, -1) THEN _
                  ?"failed setting PWM value (" & *.Errr & ")" : EXIT DO
          IF .Pwm->Value(P9_14, @realfreq, NULL) THEN _
                  ?"failed getting PWM value (" & *.Errr & ")" : EXIT DO
        CASE ELSE : EXIT DO '                                     finish
        END SELECT
        SELECT CASE AS CONST m
        CASE 3
          IF .Pwm->setValue(P9_14, freq, -1) THEN _
                  ?"failed setting PWM value (" & *.Errr & ")" : EXIT DO
          IF .Pwm->Value(P9_14, @realfreq, NULL) THEN _
                  ?"failed getting PWM value (" & *.Errr & ")" : EXIT DO
        CASE ELSE
          p = m
          IF .Qep->config(PINS(p), pmax, VHz) THEN _ 'reconfigure QEP pins
            ?"QEP pin reconfiguration failed (" & *.Errr & ")" : EXIT DO
        END SELECT
        ?!"\n" & *t(p) & " input, " & freq & "Hz (" & realfreq & "), PMax=" & pmax
      END IF
      IF .Qep->Value(PINS(p), @posi, @velo) THEN _
                         ?"Qep->Value failed (" & *.Errr & ")" : EXIT DO
      ?!"\r" & HEX(posi, 8), velo & "          ";
      SLEEP 20
    LOOP : ?
  LOOP UNTIL 1
  IF .Errr THEN SLEEP
END WITH

DELETE(io)

'' help Doxygen to dokument the main code
'&/** The main function. */
'&int main() {PruIo::PruIo(); PwmMod::setValue(); PwmMod::Value(); QepMod::config(); PruIo::config(); QepMod::Value(); PruIo::~PruIo();}