*** Settings ***
Library           SeleniumLibrary
Library           OperatingSystem

Suite Setup       Open Browser To Login Page
Suite Teardown    Close All Browsers
Test Setup        Login And Go To Shop Settings

*** Variables ***
${BASE_URL}              http://localhost:5173
${BROWSER}               chrome
${VALID USER}            admin
${VALID PASSWORD}        12345678
${TIMEOUT}               20s
${SCREEN_DIR}            screenshots

# Nav
${MENU_SETTINGS}         xpath=//a[@href='/setting/shop' or contains(@href,'/setting/shop')]

# Edit flow
${BTN_EDIT}              id=edit-settings-button
${INPUT_SHOP_NAME}       id=shop-name-input
${TEXTAREA_SHOP_ADDR}    id=shop-address-textarea
${BTN_SUBMIT}            id=shop-submit-button

# Misc waits
${SPINNERS}              css=.ant-spin,.loading,.v-overlay--active,.swal2-container
${SWAL_CONFIRM}          css=button.swal2-confirm

*** Test Cases ***
แก้ไขข้อมูลร้านค้า (ถ่ายภาพทุกขั้นตอน)
    [Documentation]    ล็อกอิน → ไปหน้า /setting/shop → แคปหน้าจอ → กดแก้ไข → กรอกชื่อ/ที่อยู่ → แคปหน้าจอ → กดยืนยัน → แคปหน้าจอ
    # 1) หน้า “การตั้งค่า” ของร้าน
    Wait Until Element Is Visible       ${MENU_SETTINGS}    ${TIMEOUT}
    Click Element                       ${MENU_SETTINGS}
    Wait Table Idle
    Create Directory                    ${SCREEN_DIR}
    Capture Page Screenshot             ${SCREEN_DIR}${/}shop_settings_page.png

    # 2) กด “แก้ไขข้อมูล”
    Wait Until Element Is Visible       ${BTN_EDIT}    ${TIMEOUT}
    Scroll Element Into View            ${BTN_EDIT}
    Click Element                       ${BTN_EDIT}
    Wait Table Idle

    # 3) กรอกฟอร์ม
    Wait Until Element Is Visible       ${INPUT_SHOP_NAME}       ${TIMEOUT}
    Clear Element Text                  ${INPUT_SHOP_NAME}
    Input Text                          ${INPUT_SHOP_NAME}       ร้านทดสอบ โปโรเจค POS

    Wait Until Element Is Visible       ${TEXTAREA_SHOP_ADDR}    ${TIMEOUT}
    Clear Element Text                  ${TEXTAREA_SHOP_ADDR}
    Input Text                          ${TEXTAREA_SHOP_ADDR}    123/45 ถนนตัวอย่าง แขวงทดสอบ เขตทดสอบ กรุงเทพฯ 10110

    Capture Page Screenshot             ${SCREEN_DIR}${/}shop_edit_filled.png

    # 4) ยืนยัน
    Scroll Element Into View            ${BTN_SUBMIT}
    Click Element                       ${BTN_SUBMIT}
    Click If Exists                     ${SWAL_CONFIRM}
    Wait Table Idle
    Capture Page Screenshot             ${SCREEN_DIR}${/}shop_edit_submitted.png

*** Keywords ***
Open Browser To Login Page
    Open Browser    ${BASE_URL}    ${BROWSER}
    Maximize Browser Window
    Set Selenium Timeout    ${TIMEOUT}

Login And Go To Shop Settings
    Wait Until Element Is Visible    css=input[name='username']    ${TIMEOUT}
    Input Text                       css=input[name='username']    ${VALID USER}
    Input Text                       css=input[name='password']    ${VALID PASSWORD}
    Click Button                     css=button[type='submit']
    Wait Table Idle
    # ไปหน้า settings ตามที่ต้องการ
    Wait Until Element Is Visible    ${MENU_SETTINGS}    ${TIMEOUT}

Wait Table Idle
    Run Keyword And Ignore Error     Wait Until Element Is Not Visible    ${SPINNERS}    6s
    Sleep    0.3s

Click If Exists
    [Arguments]    ${locator}
    ${ok}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${locator}    3s
    Run Keyword If    ${ok}    Click Element    ${locator}
