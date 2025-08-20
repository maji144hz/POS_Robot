*** Settings ***
Library           SeleniumLibrary
Library           OperatingSystem

Suite Setup       Open Browser To Login Page
Suite Teardown    Close All Browsers
Test Setup        Login And Go To Profile

*** Variables ***
${BASE_URL}                 http://localhost:5173
${BROWSER}                  chrome
${VALID USER}               admin
${VALID PASSWORD}           12345678
${TIMEOUT}                  20s
${SCREEN_DIR}               screenshots

# Profile page & menu
${PROFILE_URL}              ${BASE_URL}/profile
${PROFILE_DROPDOWN_BTN}     xpath=//div[contains(@class,'dropdown')]/button[contains(@class,'btn-ghost')]
${BTN_GO_SETTINGS}          xpath=//button[contains(normalize-space(.),'การตั้งค่า')]

# Edit form
${BTN_PROFILE_EDIT}         id=profile-edit-button
${INPUT_USERNAME}           id=edit-profile-username-input
${INPUT_PHONE}              id=edit-profile-phone-input
${BTN_SUBMIT}               id=edit-profile-submit-button

# Misc waits
${SPINNERS}                 css=.ant-spin,.loading,.v-overlay--active,.swal2-container
${SWAL_CONFIRM}             css=button.swal2-confirm

*** Test Cases ***
แก้ไขข้อมูลส่วนตัว (ถ่ายภาพทุกขั้นตอน)
    [Documentation]    ล็อกอิน → /profile → เปิดเมนูการตั้งค่า → แก้ไขข้อมูลส่วนตัว → กรอก username/phone → บันทึก
    # 1) ไปหน้าโปรไฟล์ + แคป
    Create Directory                    ${SCREEN_DIR}
    Go To                               ${PROFILE_URL}
    Wait Table Idle
    Capture Page Screenshot             ${SCREEN_DIR}${/}profile_page.png

    # 2) เปิดเมนู “การตั้งค่า” จาก dropdown
    #    เผื่อบางธีม dropdown เปิดอัตโนมัติ: ลองกดปุ่ม dropdown ก่อน แล้วกดปุ่ม "การตั้งค่า"
    Wait Until Element Is Visible       ${PROFILE_DROPDOWN_BTN}    ${TIMEOUT}
    Scroll Element Into View            ${PROFILE_DROPDOWN_BTN}
    Click Element                       ${PROFILE_DROPDOWN_BTN}
    Wait Until Element Is Visible       ${BTN_GO_SETTINGS}         ${TIMEOUT}
    Click Element                       ${BTN_GO_SETTINGS}
    Wait Table Idle
    Capture Page Screenshot             ${SCREEN_DIR}${/}profile_settings_panel.png

    # 3) กด “แก้ไขข้อมูลส่วนตัว”
    Wait Until Element Is Visible       ${BTN_PROFILE_EDIT}        ${TIMEOUT}
    Scroll Element Into View            ${BTN_PROFILE_EDIT}
    Click Element                       ${BTN_PROFILE_EDIT}
    Wait Table Idle

    # 4) กรอกข้อมูล
    Wait Until Element Is Visible       ${INPUT_USERNAME}          ${TIMEOUT}
    Clear Element Text                  ${INPUT_USERNAME}
    Input Text                          ${INPUT_USERNAME}          ผู้ใช้ทดสอบ

    Wait Until Element Is Visible       ${INPUT_PHONE}             ${TIMEOUT}
    Clear Element Text                  ${INPUT_PHONE}
    Input Text                          ${INPUT_PHONE}             0891234567    # 10 หลัก

    Capture Page Screenshot             ${SCREEN_DIR}${/}profile_edit_filled.png

    # 5) บันทึก
    Scroll Element Into View            ${BTN_SUBMIT}
    Click Element                       ${BTN_SUBMIT}
    Click If Exists                     ${SWAL_CONFIRM}
    Wait Table Idle
    Capture Page Screenshot             ${SCREEN_DIR}${/}profile_edit_submitted.png


*** Keywords ***
Open Browser To Login Page
    Open Browser    ${BASE_URL}    ${BROWSER}
    Maximize Browser Window
    Set Selenium Timeout    ${TIMEOUT}

Login And Go To Profile
    Wait Until Element Is Visible    css=input[name='username']    ${TIMEOUT}
    Input Text                       css=input[name='username']    ${VALID USER}
    Input Text                       css=input[name='password']    ${VALID PASSWORD}
    Click Button                     css=button[type='submit']
    Wait Table Idle
    # ไปหน้าโปรไฟล์โดยตรง
    Go To                            ${PROFILE_URL}
    Wait Table Idle
    # ยืนยันว่ามี dropdown ปุ่มโปรไฟล์
    Wait Until Element Is Visible    ${PROFILE_DROPDOWN_BTN}    ${TIMEOUT}

Wait Table Idle
    Run Keyword And Ignore Error     Wait Until Element Is Not Visible    ${SPINNERS}    6s
    Sleep    0.3s

Click If Exists
    [Arguments]    ${locator}
    ${ok}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${locator}    3s
    Run Keyword If    ${ok}    Click Element    ${locator}
