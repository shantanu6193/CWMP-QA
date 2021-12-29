public inherited sharing class CustomExceptionController {
    public CustomExceptionController() {

    }

    public class NoApplicationTriggerException extends Exception {}

    
    public class CustomMessageException extends Exception {}
    
    // This method used for get perticular error message after Exception
    public static String getSpecificErrorMessage(String errorMsg) {
        if(errorMsg.contains('_EXCEPTION,')) {
            String pureErrorMsg = errorMsg.substringAfter('_EXCEPTION,');
            if(pureErrorMsg.contains('Class.')) {
                pureErrorMsg = pureErrorMsg.substringBefore('Class.');
            }            
            pureErrorMsg = pureErrorMsg.Substring(0, (pureErrorMsg.length()-5));
            System.debug('pureErrorMsg_Error :' + pureErrorMsg);    
            return pureErrorMsg;
        }else if(errorMsg.contains('_VALID_RANGE,')) {          // For Currency fields limit validation error message
            String pureErrorMsg = errorMsg.substringAfter('_VALID_RANGE,');
            return pureErrorMsg;
        }else if(errorMsg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,')) {          // For Currency fields limit validation error message
            String pureErrorMsg = errorMsg.substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,');
            pureErrorMsg = pureErrorMsg.replace(':[]', '');
            return pureErrorMsg;
        }else if(errorMsg.contains('REQUIRED_FIELD_MISSING,')) {          // For Currency fields limit validation error message
            String pureErrorMsg = errorMsg.substringAfter('REQUIRED_FIELD_MISSING,');
            pureErrorMsg = pureErrorMsg.substringBefore(']:');
            pureErrorMsg = pureErrorMsg.replace('[','');
            return pureErrorMsg;
        }else {
            return errorMsg;
        }
    }
}