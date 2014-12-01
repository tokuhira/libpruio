/'* \file pruio.bi
\brief FreeBASIC header file for libpruio.

Header file for including libpruio to FreeBASIC programs. It binds the
different components together and provides all declarations.

\since 0.0
'/

#IFNDEF __PRUIO_COMPILING__
#INCLIB "pruio"
' PruIo global declarations.
#INCLUDE ONCE "pruio_globals.bi"
' Header for ADC part.
#INCLUDE ONCE "pruio_adc.bi"
' Header for GPIO part.
#INCLUDE ONCE "pruio_gpio.bi"
' Header for PWMSS part, containing modules QEP, CAP and PWM.
#INCLUDE ONCE "pruio_pwmss.bi"
' Header for TIMER part.
#INCLUDE ONCE "pruio_timer.bi"
#ENDIF

'* Version string.
#DEFINE PRUIO_VERSION "0.2.2"

'* Tell pruss_intc_mapping.bi that we use ARM33xx.
#DEFINE AM33XX
' The PRUSS driver library.
#INCLUDE ONCE "BBB/prussdrv.bi"
' PRUSS driver interrupt settings.
#INCLUDE ONCE "BBB/pruss_intc_mapping.bi"

'* The channel for PRU messages (must match PRUIO_IRPT).
#DEFINE PRUIO_CHAN CHANNEL5
'* The mask to enable PRU interrupts (must match PRUIO_IRPT).
#DEFINE PRUIO_MASK PRU_EVTOUT5_HOSTEN_MASK
'* The event for PRU messages (mapping, must match PRUIO_IRPT).
#DEFINE PRUIO_EMAP PRU_EVTOUT5
'* The event for PRU messages (must match PRUIO_IRPT).
#DEFINE PRUIO_EVNT PRU_EVTOUT_5

'* Macro to calculate the total size of an array in bytes.
#DEFINE ArrayBytes(_A_) (UBOUND(_A_) + 1) * SIZEOF(_A_)
'* Macro to check a CPU ball number (0 to 109 is valid range).
#DEFINE BallCheck(_T_,_R_) IF Ball > PRUIO_AZ_BALL THEN .Errr = @"unknown" _T_ " pin number" : RETURN _R_


/'* \brief Mask to be used in the constructor to choose PRUSS number and enable divices controls.

This enumerators are used in the constructor PruIo::PruIo() to enable
single subsystems. By default all subsystems are enabled. If a device
is not enabled, libpruio wont wake it up nor allocate memory to control
it. It just reads the version information to see if the subsystem is in
operation.

An enabled subsystem will get activated in the constructor
PruIo::PruIo() and libpruio will set its configuration. When done, the
destructor PruIo::~PruIo either disables it (when previously disabled)
or resets the initial configuration.

The first enumerator PRUIO_ACT_PRU1 is used to specify the PRU
subsystem to execute libpruio. By default the bit is set and libpruio
runs on PRU-1. See PruIo::PruIo() for further information.

\since 0.2
'/
ENUM ActivateDevice
  PRUIO_ACT_PRU1   = &b0000000000001 '*< activate PRU-1 (= default, instead of PRU-0)
  PRUIO_ACT_ADC    = &b0000000000010 '*< activate ADC
  PRUIO_ACT_GPIO0  = &b0000000000100 '*< activate GPIO-0
  PRUIO_ACT_GPIO1  = &b0000000001000 '*< activate GPIO-1
  PRUIO_ACT_GPIO2  = &b0000000010000 '*< activate GPIO-2
  PRUIO_ACT_GPIO3  = &b0000000100000 '*< activate GPIO-3
  PRUIO_ACT_PWM0   = &b0000001000000 '*< activate PWMSS-0 (including eCAP, eQEP, ePWM)
  PRUIO_ACT_PWM1   = &b0000010000000 '*< activate PWMSS-1 (including eCAP, eQEP, ePWM)
  PRUIO_ACT_PWM2   = &b0000100000000 '*< activate PWMSS-2 (including eCAP, eQEP, ePWM)
  PRUIO_ACT_TIM4   = &b0001000000000 '*< activate TIMER-4
  PRUIO_ACT_TIM5   = &b0010000000000 '*< activate TIMER-5
  PRUIO_ACT_TIM6   = &b0100000000000 '*< activate TIMER-6
  PRUIO_ACT_TIM7   = &b1000000000000 '*< activate TIMER-7
  PRUIO_DEF_ACTIVE = &b1111111111111 '*< activate all subsystems
END ENUM


/'* \brief Structure for Control Module, containing pad configurations.

This UDT contains a set of all pad control registers. This is the
muxing between CPU balls and the internal subsystem targets, the pullup
or pulldown configuration and the receiver activation.

\since 0.2
'/
TYPE BallSet
  AS UInt32 DeAd                 '*< Base address of Control Module subsystem.
  AS  UInt8 Value(PRUIO_AZ_BALL) '*< The values of the pad control registers.
END TYPE

/'* \brief Main structure, binding all components together.

This UDT glues all together. It downloads and start software on the
PRUSS, controls the initialisation and configuration processes and
reads or writes the pinmux configurations.

\since 0.0
'/
TYPE PruIo
  AS AdcUdt PTR Adc     '*< Pointer to ADC subsystem structure.
  AS GpioUdt PTR Gpio   '*< Pointer to GPIO subsystems structure.
  AS PwmssUdt PTR PwmSS '*< Pointer to PWMSS subsystems structure.
  AS TimerUdt PTR TimSS '*< Pointer to TIMER subsystems structure.
  AS PwmMod PTR Pwm     '*< Pointer to the ePWM module structure (in PWMSS subsystems).
  AS CapMod PTR Cap     '*< Pointer to the eCAP module structure (in PWMSS subsystems).
  'AS QepMod PTR Qep     '*< Pointer to the eQEP module structure (in PWMSS subsystems).

  AS ZSTRING PTR _
    Errr = 0    '*< Pointer for error messages.
  AS  UInt32 PTR DRam '*< Pointer to access PRU DRam.
  AS BallSet PTR _
    Init _      '*< The subsystems register data at start-up (to restore when finished).
  , Conf        '*< The subsystems register data used by libpruio (current local data to be uploaded by PruIo::Config() ).
  AS ANY PTR _
    ERam _      '*< Pointer to read PRU external ram.
  , DInit _     '*< Pointer to block of subsystems initial data.
  , DConf _     '*< Pointer to block of subsystems configuration data.
  , MOffs       '*< Configuration offset for modules.
  AS UInt8 PTR _
    BallInit _  '*< Pointer for original Ball configuration.
  , BallConf    '*< Pointer to ball configuration (CPU pin muxing).
  AS UInt32 _
    EAddr     _ '*< The address of the external memory (PRUSS-DDR).
  , ESize     _ '*< The size of the external memory (PRUSS-DDR).
  , DSize     _ '*< The size of a data block (DInit or DConf).
  , PruNo     _ '*< The PRU number to use (defaults to 1).
  , PruIRam   _ '*< The PRU instruction ram to load.
  , PruDRam     '*< The PRU data ram.
  AS INT16 _
    ParOffs _   '*< The offset for the parameters of a module.
  , DevAct      '*< Active subsystems.
  AS STRING _
    MuxAcc      '*< Path for pinmuxing.

  '* interrupt settings (we also set default interrupts, so that the other PRUSS can be used in parallel)
  AS tpruss_intc_initdata IntcInit = _
    TYPE<tpruss_intc_initdata>( _
      { PRU0_PRU1_INTERRUPT _
      , PRU1_PRU0_INTERRUPT _
      , PRU0_ARM_INTERRUPT _
      , PRU1_ARM_INTERRUPT _
      , ARM_PRU0_INTERRUPT _
      , ARM_PRU1_INTERRUPT _
      , PRUIO_IRPT _
      , CAST(BYTE, -1) }, _
      { TYPE<tsysevt_to_channel_map>(PRU0_PRU1_INTERRUPT, CHANNEL1) _
      , TYPE<tsysevt_to_channel_map>(PRU1_PRU0_INTERRUPT, CHANNEL0) _
      , TYPE<tsysevt_to_channel_map>(PRU0_ARM_INTERRUPT, CHANNEL2) _
      , TYPE<tsysevt_to_channel_map>(PRU1_ARM_INTERRUPT, CHANNEL3) _
      , TYPE<tsysevt_to_channel_map>(ARM_PRU0_INTERRUPT, CHANNEL0) _
      , TYPE<tsysevt_to_channel_map>(ARM_PRU1_INTERRUPT, CHANNEL1) _
      , TYPE<tsysevt_to_channel_map>(PRUIO_IRPT, PRUIO_CHAN) _
      , TYPE<tsysevt_to_channel_map>(-1, -1)}, _
      { TYPE<tchannel_to_host_map>(CHANNEL0, PRU0) _
      , TYPE<tchannel_to_host_map>(CHANNEL1, PRU1) _
      , TYPE<tchannel_to_host_map>(CHANNEL2, PRU_EVTOUT0) _
      , TYPE<tchannel_to_host_map>(CHANNEL3, PRU_EVTOUT1) _
      , TYPE<tchannel_to_host_map>(PRUIO_CHAN, PRUIO_EMAP) _
      , TYPE<tchannel_to_host_map>(-1, -1) }, _
      (PRU0_HOSTEN_MASK OR PRU1_HOSTEN_MASK OR _
       PRU_EVTOUT0_HOSTEN_MASK OR PRU_EVTOUT1_HOSTEN_MASK OR PRUIO_MASK) _
      )

  '* list of GPIO numbers, corresponding to ball index
  AS UInt8 BallGpio(PRUIO_AZ_BALL) = { _
     32,  33,  34,  35,  36,   37,  38,  39,  22,  23 _
  ,  26,  27,  44,  45,  46,   47,  48,  49,  50,  51 _ ' 10
  ,  52,  53,  54,  55,  56,   57,  58,  59,  30,  31 _
  ,  60,  61,  62,  63,  64,   65,  66,  67,  68,  69 _ ' 30
  ,  70,  71,  72,  73,  74,   75,  76,  77,  78,  79 _
  ,  80,  81,   8,   9,  10,   11,  86,  87,  88,  89 _ ' 50
  ,  90,  91,  92,  93,  94,   95,  96,  97,  98,  99 _
  , 100,  16,  17,  21,  28,  105, 106,  82,  83,  84 _ ' 70
  ,  85,  29,   0,   1,   2,    3,   4,   5,   6,   7 _
  ,  40,  41,  42,  43,  12,   13,  14,  15, 101, 102 _ ' 90
  , 110, 111, 112, 113, 114,  115, 116, 117,  19,  20}

  DECLARE CONSTRUCTOR( _
    BYVAL AS UInt16 = PRUIO_DEF_ACTIVE _
  , BYVAL AS UInt8  = PRUIO_DEF_AVRAGE _
  , BYVAL AS UInt32 = PRUIO_DEF_ODELAY _
  , BYVAL AS UInt8  = PRUIO_DEF_SDELAY)
  DECLARE DESTRUCTOR()
  DECLARE FUNCTION config CDECL( _
    BYVAL AS UInt32 = PRUIO_DEF_SAMPLS _
  , BYVAL AS UInt32 = PRUIO_DEF_STPMSK _
  , BYVAL AS UInt32 = PRUIO_DEF_TIMERV _
  , BYVAL AS UInt16 = PRUIO_DEF_LSLMOD) AS ZSTRING PTR
  DECLARE FUNCTION Pin CDECL( _
    BYVAL AS UInt8 _
  , BYVAL AS UInt32 = 0) AS ZSTRING PTR
  DECLARE FUNCTION setPin CDECL( _
    BYVAL AS UInt8 _
  , BYVAL AS UInt8) AS ZSTRING PTR
  DECLARE FUNCTION nameBall CDECL( _
    BYVAL AS UInt8) AS ZSTRING PTR
  DECLARE FUNCTION rb_start CDECL() AS ZSTRING PTR
  DECLARE FUNCTION mm_start CDECL( _
    BYVAL AS UInt32 = 0 _
  , BYVAL AS UInt32 = 0 _
  , BYVAL AS UInt32 = 0 _
  , BYVAL AS UInt32 = 0) AS ZSTRING PTR
END TYPE

