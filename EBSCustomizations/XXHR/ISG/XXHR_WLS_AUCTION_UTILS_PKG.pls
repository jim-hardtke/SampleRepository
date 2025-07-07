CREATE OR REPLACE PACKAGE xxhr_wls_auction_utils_pkg AS
  /* $Header: xxhr_wls_auction_utils_pkg.pls */
  /*#
  * Cox Carton Details Publish Package
  * @rep:scope public
  * @rep:product ONT
  * @rep:lifecycle active
  * @rep:displayname Cox Carton Details Publish Package
  * @rep:compatibility S
  * @rep:category BUSINESS_ENTITY ONT
  */
-- **************************************************************************
-- Program Name       : xxhr_wls_auction_utils_pkg.pks
-- Purpose            : Utility package used by wirleless auction page
-- History:
---------------------------------------------------------------------------
-- Date          Author                      Description
---------------------------------------------------------------------------
-- 09/19/2024   Pavan Nagaraju             Initial version
-- ************************************************************************* 

TYPE serial_number_rec_type  IS RECORD (serial_number VARCHAR2(30));

TYPE serial_number_tbl_type  IS TABLE OF serial_number_rec_type;


PROCEDURE process_freeze (p_auc_tbl xxceoe_wls_auc_tbl_type,
                          x_return_status out varchar2,
						  x_return_message out varchar2);

PROCEDURE extract_carton_dtls (p_carton_id in varchar2,
                               p_action in varchar2,
							   x_carton_tbl out serial_number_tbl_type,
							   x_ret_code out varchar2,
							   x_ret_message out varchar2)
 /*#
    * This procedure extracts wireless device carton details from Oracle
    * @param p_carton_id               IN  VARCHAR2
    * @param p_action             	   IN  VARCHAR2
    * @param x_carton_tbl              OUT xxceoe_wls_carton_tbl_type
    * @param x_ret_code                OUT VARCHAR2
    * @param x_ret_message             OUT VARCHAR2
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Publish Cox Wireless Carton Details
    * @rep:compatibility S
    * @rep:category BUSINESS_ENTITY ONT
    */
;
						  
PROCEDURE update_freeze_status (p_carton_id in varchar2,
                                p_action in varchar2,
								p_status in varchar2,
								p_status_msg in varchar2,
								x_ret_code out varchar2,
								x_ret_message out varchar2)
/*#
    * This procedure updates carton status in Oracle
    * @param p_carton_id               IN  VARCHAR2
    * @param p_action             	   IN  VARCHAR2
	* @param p_status                  IN  VARCHAR2
    * @param p_status_msg              IN  VARCHAR2
    * @param x_ret_code                OUT VARCHAR2
    * @param x_ret_message             OUT VARCHAR2
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Update Cox Wireless Carton Status
    * @rep:compatibility S
    * @rep:category BUSINESS_ENTITY ONT
    */								
;		

				
						
PROCEDURE create_order (p_auc_tbl in xxceoe_wls_auc_tbl_type,
                        x_return_status out varchar2,
						x_return_message out varchar2);

END xxhr_wls_auction_utils_pkg;