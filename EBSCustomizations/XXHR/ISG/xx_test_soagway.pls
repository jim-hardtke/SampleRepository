CREATE OR REPLACE PACKAGE xx_test_soagway AS
/* $Header: $ */
/*#
* This package returns different data from Financials (GL).
* @rep:scope public
* @rep:product gl
* @rep:displayname xx_test_soagway
* @rep:lifecycle active
* @rep:compatibility S
* @rep:category BUSINESS_ENTITY GL_ACCOUNT_COMBINATION
*/

/*#
* Returns CCID
* @param P_SEGMENT1 varchar2 Segment 1
* @param P_SEGMENT2 varchar2 Segment 2
* @param P_SEGMENT3 varchar2 Segment 3
* @param P_SEGMENT4 varchar2 Segment 4
* @param P_SEGMENT5 varchar2 Segment 5
* @return CCID
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Return CCID
*/
FUNCTION get_ccid (P_SEGMENT1 IN VARCHAR2,
                   P_SEGMENT2 IN VARCHAR2,
                   P_SEGMENT3 IN VARCHAR2,
                   P_SEGMENT4 IN VARCHAR2,
                   P_SEGMENT5 IN VARCHAR2) RETURN NUMBER;

END xx_test_soagway;
