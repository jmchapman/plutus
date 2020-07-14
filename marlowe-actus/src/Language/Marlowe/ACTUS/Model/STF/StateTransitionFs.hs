{-# LANGUAGE RecordWildCards #-}

module Language.Marlowe.ACTUS.Model.STF.StateTransitionFs (stateTransitionFs) where

import Language.Marlowe
import Language.Marlowe.ACTUS.Definitions.BusinessEvents
import Language.Marlowe.ACTUS.Model.STF.StateTransitionModel
import Language.Marlowe.ACTUS.Definitions.ContractTerms
import Language.Marlowe.ACTUS.Definitions.Schedule
import Language.Marlowe.ACTUS.Model.SCHED.ContractSchedule
import Language.Marlowe.ACTUS.MarloweCompat
import Language.Marlowe.ACTUS.Ops
import Data.Maybe
import Data.Time

import qualified Data.List as L

import Language.Marlowe.ACTUS.Model.Utility.DateShift
import Language.Marlowe.ACTUS.Model.Utility.ScheduleGenerator
    ( sup, inf )

shift :: ScheduleConfig -> Day -> ShiftedDay
shift = applyBDCWithCfg

stateTransitionFs :: EventType -> ContractTerms -> Integer -> Day -> Contract -> Contract
stateTransitionFs ev terms@ContractTerms{..} t curDate continue = 
    let 
        __IPANX = marloweDate <$> _IPANX
        __IPNR  = constnt <$> _IPNR
        __IPAC  = constnt <$> _IPAC
        __NT    = constnt _NT
        __FEB   = enum _FEB
        __FER   = constnt _FER
        (__RRLF, __RRLC, __RRPC, __RRPF, __RRMLT, __RRSP) =
                ( constnt _RRLF
                , constnt _RRLC
                , constnt _RRPC
                , constnt _RRPF
                , constnt _RRMLT
                , constnt _RRSP
                )
        __RRNXT            = constnt <$> _RRNXT
        __SCIED            = constnt _SCIED
        __o_rf_RRMO        = useval "o_rf_RRMO" t
        __o_rf_SCMO        = useval "o_rf_SCMO" t
        __pp_payoff        = useval "pp_payoff" t

        -- dates:
        t0                 = _SD
        time               = SlotIntervalStart
        fpSchedule         = fromMaybe [shift scfg t0] $ schedule FP terms
        tfp_minus          = marloweDate $ calculationDay $ sup fpSchedule curDate
        tfp_plus           = marloweDate $ calculationDay $ inf fpSchedule curDate

        y_sd_t             = _y _DCC (useval "sd" t) time undefined
        y_tfpminus_t       = _y _DCC tfp_minus time undefined
        y_tfpminus_tfpplus = _y _DCC tfp_minus tfp_plus undefined
        y_ipanx_t          = _y _DCC (fromJust __IPANX) time undefined
                        
    in case contractType of
        PAM -> 
            stateTransitionMarlowe ev t continue $ \event st -> case event of 
                AD   -> _STF_AD_PAM st time y_sd_t
                IED  -> _STF_IED_PAM st time y_ipanx_t __IPNR __IPANX _CNTRL __IPAC __NT
                MD   -> _STF_MD_PAM st time
                PP   -> _STF_PP_PAM st time __pp_payoff y_sd_t y_tfpminus_t y_tfpminus_tfpplus __FEB __FER _CNTRL
                PY   -> _STF_PY_PAM st time y_sd_t y_tfpminus_t y_tfpminus_tfpplus __FEB __FER _CNTRL
                FP   -> _STF_FP_PAM st time y_sd_t
                PRD  -> _STF_PRD_PAM st time y_sd_t y_tfpminus_t y_tfpminus_tfpplus __FEB __FER _CNTRL 
                TD   -> _STF_IP_PAM st time y_sd_t y_tfpminus_t y_tfpminus_tfpplus __FEB __FER _CNTRL 
                IP   -> _STF_IPCI_PAM st time y_sd_t y_tfpminus_t y_tfpminus_tfpplus __FEB __FER _CNTRL
                IPCI -> _STF_IPCI_PAM st time y_sd_t y_tfpminus_t y_tfpminus_tfpplus __FEB __FER _CNTRL
                RR   -> _STF_RR_PAM st time y_sd_t y_tfpminus_t y_tfpminus_tfpplus __FEB __FER _CNTRL __RRLF __RRLC __RRPC __RRPF __RRMLT __RRSP __o_rf_RRMO
                RRF  -> _STF_RRF_PAM st time y_sd_t y_tfpminus_t y_tfpminus_tfpplus __FEB __FER _CNTRL __RRNXT
                SC   -> _STF_SC_PAM st time y_sd_t y_tfpminus_t y_tfpminus_tfpplus __FEB __FER _CNTRL _SCEF __o_rf_SCMO __SCIED
                CE   -> _STF_CE_PAM st time y_sd_t
                _    -> st
        LAM -> undefined


     

    
     
    
     
    