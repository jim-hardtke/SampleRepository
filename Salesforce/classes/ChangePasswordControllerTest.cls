/**
 * An apex page controller that exposes the change password functionality.
 */
@IsTest public with sharing class ChangePasswordControllerTest {
    @IsTest(SeeAllData=true) public static void testChangePasswordController() {
        // Instantiate a new controller with all parameters in the page
        ChangePasswordController controller = new ChangePasswordController();
        controller.oldPassword = '123456';
        controller.newPassword = 'qwerty3'; 
        controller.verifyNewPassword = 'qwerty3';                
        system.debug('adding a simple comment===');
        System.assertEquals(controller.changePassword(),null);                           
    }    
}