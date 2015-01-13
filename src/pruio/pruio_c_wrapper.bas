/'* \file pruio_c_wrapper.bas
\brief The main source code of the C wrapper for libpruio.

This file provides the libpruio functions in a C compatible syntax to
use libpruio in polyglot applications or to create language bindings
for non-C languages.

Licence: LGPLv2 (http://www.gnu.org/licenses/lgpl-2.0.html)

Copyright 2014-2015 by Thomas{ dOt ]Freiherr[ At ]gmx[ DoT }net


compile by (static and dynamic library)

./build

'/


' PruIo global declarations.
#include ONCE "pruio_globals.bi"
' Header for ADC part.
#include ONCE "pruio_adc.bi"
' Header for GPIO part.
#include ONCE "pruio_gpio.bi"
' Header for PWMSS part, containing modules QEP, CAP and PWM.
#include ONCE "pruio_pwmss.bi"
'' Header for TIMER part.
'#include ONCE "pruio_timer.bi"
' driver header file
#include ONCE "pruio.bi"

'* \brief Wrapper function for constructor PruIo::PruIo().
FUNCTION pruio_new CDECL ALIAS "pruio_new"( _
    BYVAL Act AS UInt16 = PRUIO_DEF_ACTIVE _
  , BYVAL  Av AS UInt8  = PRUIO_DEF_AVRAGE _
  , BYVAL OpD AS UInt32 = PRUIO_DEF_ODELAY _
  , BYVAL SaD AS UInt8  = PRUIO_DEF_SDELAY) AS PruIo PTR EXPORT

  RETURN NEW PruIo(Act, Av, OpD, SaD)
END FUNCTION

'* \brief Wrapper function for destructor PruIo::~PruIo.
SUB pruio_destroy CDECL ALIAS "pruio_destroy"( _
    BYVAL Io AS PruIo PTR) EXPORT

  IF Io THEN DELETE Io : Io = 0
END SUB

'* \brief Wrapper function for PruIo::config().
FUNCTION pruio_config CDECL ALIAS "pruio_config"( _
    BYVAL Io AS PruIo PTR _
  , BYVAL Samp AS UInt32 _
  , BYVAL Mask AS UInt32 _
  , BYVAL  Tmr AS UInt32 _
  , BYVAL  Mds AS UInt16) AS ZSTRING PTR EXPORT

  RETURN Io->config(Samp, Mask, Tmr, Mds)
END FUNCTION

'* \brief Wrapper function for PruIo::Pin().
FUNCTION pruio_Pin CDECL ALIAS "pruio_Pin"( _
    BYVAL Io AS PruIo PTR _
  , BYVAL Ball AS UInt8) AS ZSTRING PTR EXPORT

  RETURN Io->Pin(Ball)
END FUNCTION

'* \brief Wrapper function for PruIo::mm_start().
FUNCTION pruio_mm_start CDECL ALIAS "pruio_mm_start"( _
    BYVAL Io AS PruIo PTR _
  , BYVAL Trg1 AS UInt32 _
  , BYVAL Trg2 AS UInt32 _
  , BYVAL Trg3 AS UInt32 _
  , BYVAL Trg4 AS UInt32) AS ZSTRING PTR EXPORT

  RETURN Io->mm_start(Trg1, Trg2, Trg3, Trg4)
END FUNCTION

'* \brief Wrapper function for PruIo::rb_start().
FUNCTION pruio_rb_start CDECL ALIAS "pruio_rb_start"( _
    BYVAL Io AS PruIo PTR) AS ZSTRING PTR EXPORT

  RETURN Io->rb_start()
END FUNCTION


'* \brief Wrapper function for AdcUdt::setStep().
FUNCTION pruio_adc_setStep CDECL ALIAS "pruio_adc_setStep"( _
    BYVAL Io AS PruIo PTR _
  , BYVAL Stp AS UInt8 _
  , BYVAL ChN AS UInt8 _
  , BYVAL  Av AS UInt8 _
  , BYVAL SaD AS UInt8 _
  , BYVAL OpD AS UInt32) AS ZSTRING PTR EXPORT

  RETURN Io->Adc->setStep(Stp, ChN, Av, SaD, OpD)
END FUNCTION

'* \brief Wrapper function for AdcUdt::mm_trg_pin().
FUNCTION pruio_adc_mm_trg_pin CDECL ALIAS "pruio_adc_mm_trg_pin"( _
    BYVAL Io AS PruIo PTR _
  , BYVAL Ball AS UInt8 _
  , BYVAL GpioV AS UInt8 _
  , BYVAL Skip AS UInt16) AS UInt32 EXPORT

  RETURN Io->Adc->mm_trg_pin(Ball, GpioV, Skip)
END FUNCTION

'* \brief Wrapper function for AdcUdt::mm_trg_ain().
FUNCTION pruio_adc_mm_trg_ain CDECL ALIAS "pruio_adc_mm_trg_ain"( _
    BYVAL Io AS PruIo PTR _
  , BYVAL Stp AS UInt8 _
  , BYVAL AdcV AS Int32 _
  , BYVAL Rela AS UInt8 _
  , BYVAL Skip AS UInt16) AS UInt32 EXPORT

  RETURN Io->Adc->mm_trg_ain(Stp, AdcV, Rela, Skip)
END FUNCTION

'* \brief Wrapper function for AdcUdt::mm_trg_pre().
FUNCTION pruio_adc_mm_trg_pre CDECL ALIAS "pruio_adc_mm_trg_pre"( _
    BYVAL Io AS PruIo PTR _
  , BYVAL Stp AS UInt8 _
  , BYVAL AdcV AS Int32 _
  , BYVAL Samp AS UInt16 _
  , BYVAL Rela AS UInt8) AS UInt32 EXPORT

  RETURN Io->Adc->mm_trg_pre(Stp, AdcV, Samp, Rela)
END FUNCTION


'* \brief Wrapper function for GpioUdt::config().
FUNCTION pruio_gpio_config CDECL ALIAS "pruio_gpio_config"( _
    BYVAL Io AS PruIo PTR _
  , BYVAL Ball AS UInt8 _
  , BYVAL Modus AS UInt8) AS ZSTRING PTR EXPORT

  RETURN Io->Gpio->config(Ball, Modus)
END FUNCTION

'* \brief Wrapper function for GpioUdt::setValue().
FUNCTION pruio_gpio_setValue CDECL ALIAS "pruio_gpio_setValue"( _
    BYVAL Io AS PruIo PTR _
  , BYVAL Ball AS UInt8 _
  , BYVAL Modus AS UInt8) AS ZSTRING PTR EXPORT

  RETURN Io->Gpio->setValue(Ball, Modus)
END FUNCTION

'* \brief Wrapper function for GpioUdt::Value().
FUNCTION pruio_gpio_Value CDECL ALIAS "pruio_gpio_Value"( _
    BYVAL Io AS PruIo PTR _
  , BYVAL Ball AS UInt8) AS UInt32 EXPORT

  RETURN Io->Gpio->Value(Ball)
END FUNCTION


'* \brief Wrapper function for CapMod::config().
FUNCTION pruio_cap_config CDECL ALIAS "pruio_cap_config"( _
    BYVAL Io AS PruIo PTR _
  , BYVAL Ball AS UInt8 _
  , BYVAL FLow AS Float_t = 0.) AS ZSTRING PTR EXPORT

  RETURN Io->Cap->config(Ball, FLow)
END FUNCTION

'* \brief Wrapper function for CapMod::Value().
FUNCTION pruio_cap_Value CDECL ALIAS "pruio_cap_Value"( _
    BYVAL Io AS PruIo PTR _
  , BYVAL Ball AS UInt8 _
  , BYVAL Hz AS Float_t PTR = 0 _
  , BYVAL Du AS Float_t PTR = 0) AS ZSTRING PTR EXPORT

  RETURN Io->Cap->Value(Ball, Hz, Du)
END FUNCTION


'* \brief Wrapper function for QepMod::config().
FUNCTION pruio_qep_config CDECL ALIAS "pruio_qep_config"( _
    BYVAL Io AS PruIo PTR _
  , BYVAL Ball AS UInt8 _
  , BYVAL PMax AS UInt32 = 0 _
  , BYVAL VHz AS Float_t = 25. _
  , BYVAL Scale AS Float_t = 1. _
  , BYVAL Mo AS UInt8 = 0) AS ZSTRING PTR EXPORT

  RETURN Io->Qep->config(Ball, PMax, VHz, Scale, Mo)
END FUNCTION

'* \brief Wrapper function for QepMod::Value().
FUNCTION pruio_qep_Value CDECL ALIAS "pruio_qep_Value"( _
    BYVAL Io AS PruIo PTR _
  , BYVAL Ball AS UInt8 _
  , BYVAL Posi AS UInt32 PTR = 0 _
  , BYVAL Velo AS Float_t PTR = 0) AS ZSTRING PTR EXPORT

  RETURN Io->Qep->Value(Ball, Posi, Velo)
END FUNCTION


'* \brief Wrapper function for PwmMod::Value().
FUNCTION pruio_pwm_Value CDECL ALIAS "pruio_pwm_Value"( _
    BYVAL Io AS PruIo PTR _
  , BYVAL Ball AS UInt8 _
  , BYVAL Hz AS Float_t PTR = 0 _
  , BYVAL Du AS Float_t PTR = 0) AS ZSTRING PTR EXPORT

  RETURN Io->Pwm->Value(Ball, Hz, Du)
END FUNCTION

'* \brief Wrapper function for PwmMod::setValue().
FUNCTION pruio_pwm_setValue CDECL ALIAS "pruio_pwm_setValue"( _
    BYVAL Io AS PruIo PTR _
  , BYVAL Ball AS UInt8 _
  , BYVAL Hz AS Float_t _
  , BYVAL Du AS Float_t) AS ZSTRING PTR EXPORT

  RETURN Io->Pwm->setValue(Ball, Hz, Du)
END FUNCTION


