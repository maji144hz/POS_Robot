*** Settings ***
Library           SeleniumLibrary
Library           OperatingSystem

Suite Setup       Open Browser To Login Page
Suite Teardown    Close All Browsers
Test Setup        Login To System

*** Variables ***
${BASE_URL}                               http://localhost:5173
${BROWSER}                                chrome
${VALID USER}                             admin1
${VALID PASSWORD}                         12345678
${TIMEOUT}                                20s
${SCREEN_DIR}                             screenshots

# ===== Promotions page =====
${PROMO_URL}                              ${BASE_URL}/management/promotions
${BTN_GO_CREATE_PROMO}                    id=create-promotion-button

# ===== Create form fields =====
${INPUT_PROMO_NAME}                       id=create-promotion-name-input
${INPUT_START_DATE}                       id=create-promotion-start-date
${INPUT_END_DATE}                         id=create-promotion-end-date

# Product combobox
${INPUT_PRODUCT_COMBO}                    id=create-promotion-product-combobox
${PRODUCT_NAME}                           น้ำยาล้างจาน
# ตัวเลือกจากรายการ (HeadlessUI มักเรนเดอร์เป็น span ข้อความ)
${PRODUCT_OPTION_BY_TEXT}                 xpath=//span[normalize-space(.)='${PRODUCT_NAME}']

# Lot list (เลือกล็อตแรก หรือหาโดยข้อความก็ได้)
${LOT_FIRST_CHECKBOX}                     xpath=(//div[contains(@class,'max-h-40')]//label//input[@type='checkbox'])[1]
# ถ้าต้องเลือกตามข้อความ LOT001 ใช้ตัวนี้แทน: (ปลดคอมเมนต์ถ้าจำเป็น)
# ${LOT_BY_TEXT}                          xpath=//label[.//span[contains(normalize-space(.),'LOT001')]]//input[@type='checkbox']

# Discounted price
${INPUT_DISCOUNT_PRICE}                   id=create-promotion-discounted-price-input

# Save button (รองรับหลายแบบ)
${BTN_SAVE_OPT1}                          id=create-promotion-submit-button
${BTN_SAVE_OPT2}                          xpath=//button[normalize-space()='บันทึกข้อมูล' or normalize-space()='บันทึก']
${BTN_SAVE_OPT3}                          css=button.btn-success, button.bg-green-500

# Misc waits/dialogs
${SPINNERS}                               css=.ant-spin,.loading,.v-overlay--active,.swal2-container
${SWAL_CONFIRM}                           css=button.swal2-confirm

# ===== Test data =====
${PROMO_NAME_VAL}                         น้ำยาล้างจาน
${START_DATE_VAL}                         18/08/2025
${END_DATE_VAL}                           18/09/2025
${DISCOUNT_PRICE_VAL}                     6


*** Test Cases ***
สร้างโปรโมชั่น (เลือกสินค้า+ล็อต กำหนดช่วงเวลา และราคาโปร)
    [Documentation]    ล็อกอิน → ไปหน้าโปรโมชั่น → เพิ่มโปรโมชั่น → กรอกชื่อ/วันที่ → เลือกสินค้าและล็อต → ใส่ราคา → บันทึก
    Create Directory                       ${SCREEN_DIR}

    # 1) ไปหน้าโปรโมชั่น และกด "เพิ่มโปรโมชั่น"
    Go To                                  ${PROMO_URL}
    Wait Until Element Is Visible          ${BTN_GO_CREATE_PROMO}    ${TIMEOUT}
    Click Element                          ${BTN_GO_CREATE_PROMO}
    Wait Table Idle

    # 2) กรอกชื่อ + วันที่เริ่ม/สิ้นสุด (react-datepicker แบบ input[type=text])
    Wait Until Element Is Visible          ${INPUT_PROMO_NAME}       ${TIMEOUT}
    Clear Element Text                     ${INPUT_PROMO_NAME}
    Input Text                             ${INPUT_PROMO_NAME}       ${PROMO_NAME_VAL}

    Clear Element Text                     ${INPUT_START_DATE}
    Input Text                             ${INPUT_START_DATE}       ${START_DATE_VAL}
    Sleep    0.2s

    Clear Element Text                     ${INPUT_END_DATE}
    Input Text                             ${INPUT_END_DATE}         ${END_DATE_VAL}
    Sleep    0.2s

    # 3) เลือกสินค้าใน combobox
    Wait Until Element Is Visible          ${INPUT_PRODUCT_COMBO}    ${TIMEOUT}
    Click Element                          ${INPUT_PRODUCT_COMBO}
    Clear Element Text                     ${INPUT_PRODUCT_COMBO}
    Input Text                             ${INPUT_PRODUCT_COMBO}    ${PRODUCT_NAME}
    Sleep    0.3s
    # เลือก option ตามข้อความสินค้า
    Wait Until Page Contains Element       ${PRODUCT_OPTION_BY_TEXT}    ${TIMEOUT}
    Click Element                          ${PRODUCT_OPTION_BY_TEXT}
    Sleep    0.2s

    # 4) เลือกล็อต (ติ๊กเช็คบ็อกซ์แรกในรายการ)
    Wait Until Page Contains Element       ${LOT_FIRST_CHECKBOX}     ${TIMEOUT}
    Click Element                          ${LOT_FIRST_CHECKBOX}
    Sleep    0.2s

    # 5) ใส่ราคาโปรโมชั่น
    Wait Until Element Is Visible          ${INPUT_DISCOUNT_PRICE}   ${TIMEOUT}
    Clear Element Text                     ${INPUT_DISCOUNT_PRICE}
    Input Text                             ${INPUT_DISCOUNT_PRICE}   ${DISCOUNT_PRICE_VAL}

    # 6) บันทึก
    Click Save Promotion
    Click If Exists                        ${SWAL_CONFIRM}
    Wait Table Idle


*** Keywords ***
Open Browser To Login Page
    Open Browser    ${BASE_URL}    ${BROWSER}
    Maximize Browser Window
    Set Selenium Timeout    ${TIMEOUT}

Login To System
    Wait Until Element Is Visible    css=input[name='username']    ${TIMEOUT}
    Input Text                       css=input[name='username']    ${VALID USER}
    Input Text                       css=input[name='password']    ${VALID PASSWORD}
    Click Button                     css=button[type='submit']
    Wait Table Idle

Click Save Promotion
    ${clicked}=    Run Keyword And Return Status    Click Element    ${BTN_SAVE_OPT1}
    Run Keyword If    ${clicked}    Return From Keyword
    ${has2}=    Run Keyword And Return Status    Wait Until Page Contains Element    ${BTN_SAVE_OPT2}    2s
    Run Keyword If    ${has2}    Click Element    ${BTN_SAVE_OPT2}
    Run Keyword If    ${has2}    Return From Keyword
    ${has3}=    Run Keyword And Return Status    Wait Until Page Contains Element    ${BTN_SAVE_OPT3}    2s
    Run Keyword If    ${has3}    Click Element    ${BTN_SAVE_OPT3}
    Run Keyword If    ${has3}    Return From Keyword
    Fail    ไม่พบปุ่มบันทึกโปรโมชั่น (โปรดตรวจสอบ locator ของปุ่มบันทึกในหน้า)

Wait Table Idle
    Run Keyword And Ignore Error     Wait Until Element Is Not Visible    ${SPINNERS}    6s
    Sleep    0.3s

Click If Exists
    [Arguments]    ${locator}
    ${ok}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${locator}    3s
    Run Keyword If    ${ok}    Click Element    ${locator}
