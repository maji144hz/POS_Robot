*** Settings ***
Library           SeleniumLibrary
Library           OperatingSystem
Library           random

Suite Setup       Open Browser To Login Page
Suite Teardown    Close All Browsers
Test Setup        Login And Go To Status Page

*** Variables ***
${BASE_URL}              http://localhost:5173
${BROWSER}               chrome
${VALID USER}            admin
${VALID PASSWORD}        12345678
${TIMEOUT}               20s

${STATUS_BASE}           ทดสอบสถานะ

# ===== Locators: สถานะสินค้า =====
# Create
${BTN_ADD_STATUS}        xpath=//button[.//span[contains(normalize-space(.),'เพิ่มสถานะสินค้า')] or contains(@data-tip,'เพิ่มสถานะสินค้า')]
${INPUT_STATUS}          xpath=//input[@placeholder='ชื่อสถานะสินค้า' or @id='create-status-name-input']
${BTN_SAVE_CREATE}       xpath=//button[contains(normalize-space(.),'บันทึก') or contains(normalize-space(.),'บันทึกข้อมูล')]

# Search
${SEARCH_STATUS}         id=status-search-input

# Edit (กดปุ่มแก้ไขโดยตรงหลังกรอง)
${BTN_EDIT_SINGLE}       xpath=(//button[@title='แก้ไขสถานะสินค้า' or starts-with(@id,'edit-status-button-')])[1]
${EDIT_INPUT}            id=edit-status-name-input
${BTN_SAVE_EDIT}         xpath=//button[contains(normalize-space(.),'บันทึกข้อมูล') or contains(normalize-space(.),'บันทึก')]

# Misc
${SPINNERS}              css=.ant-spin,.loading,.v-overlay--active,.swal2-container
${SWAL_CONFIRM}          css=button.swal2-confirm


*** Test Cases ***
เพิ่มและแก้ไขสถานะสินค้า
    ${r1}=            Evaluate    random.randint(1000, 9999)    random
    ${old}=           Set Variable    ${STATUS_BASE} ${r1}
    ${r2}=            Evaluate    random.randint(1000, 9999)    random
    ${new}=           Set Variable    ${STATUS_BASE} ${r2}

    Log To Console    สร้างสถานะ: ${old}
    Create Status                  ${old}

    Log To Console    ค้นหาเพื่อแก้ไข: ${old}
    Apply Status Search Filter     ${old}

    Log To Console    แก้ไขชื่อเป็น: ${new}
    Click Status Edit Button
    Fill Status Edit And Save      ${new}

    Log To Console    ตรวจสอบชื่อใหม่: ${new}
    Apply Status Search Filter     ${new}
    Page Should Contain            ${new}


*** Keywords ***
# ===== Browser & Navigate =====
Open Browser To Login Page
    Open Browser    ${BASE_URL}    ${BROWSER}
    Maximize Browser Window
    Set Selenium Timeout    ${TIMEOUT}

Login And Go To Status Page
    Wait Until Element Is Visible    css=input[name='username']    ${TIMEOUT}
    Input Text    css=input[name='username']    ${VALID USER}
    Input Text    css=input[name='password']    ${VALID PASSWORD}
    Click Button  css=button[type='submit']
    Wait Until Element Is Visible    xpath=//span[contains(text(),'จัดการ')]    ${TIMEOUT}
    Click Element    xpath=//span[contains(text(),'จัดการ')]
    ${has_manage}=    Run Keyword And Return Status    Page Should Contain Element    xpath=//a[contains(normalize-space(.),'จัดการสถานะสินค้า')]
    Run Keyword If    ${has_manage}                 Click Element    xpath=//a[contains(normalize-space(.),'จัดการสถานะสินค้า')]
    Run Keyword If    not ${has_manage}             Click Element    xpath=//a[contains(normalize-space(.),'สถานะสินค้า')]
    Wait Until Element Is Visible    ${BTN_ADD_STATUS}    ${TIMEOUT}

# ===== Create =====
Create Status
    [Arguments]    ${name}
    Click Element                         ${BTN_ADD_STATUS}
    Wait Until Element Is Visible         ${INPUT_STATUS}    ${TIMEOUT}
    Clear Element Text                    ${INPUT_STATUS}
    Input Text                            ${INPUT_STATUS}    ${name}
    Click Element                         ${BTN_SAVE_CREATE}
    Click If Exists                       ${SWAL_CONFIRM}
    Wait Until Element Is Not Visible     ${INPUT_STATUS}    ${TIMEOUT}
    Wait Table Idle

# ===== Search =====
Apply Status Search Filter
    [Arguments]    ${name}
    Wait Until Element Is Visible    ${SEARCH_STATUS}    ${TIMEOUT}
    Press Keys                       ${SEARCH_STATUS}    CTRL+A
    Press Keys                       ${SEARCH_STATUS}    BACKSPACE
    Input Text                       ${SEARCH_STATUS}    ${name}
    Press Keys                       ${SEARCH_STATUS}    ENTER
    Wait Table Idle

Wait Table Idle
    Run Keyword And Ignore Error     Wait Until Element Is Not Visible    ${SPINNERS}    5s
    Sleep    0.3s

# ===== Edit =====
Click Status Edit Button
    Wait Until Page Contains Element    ${BTN_EDIT_SINGLE}    ${TIMEOUT}
    Scroll Element Into View            ${BTN_EDIT_SINGLE}
    ${clicked}=    Run Keyword And Return Status    Click Element    ${BTN_EDIT_SINGLE}
    Run Keyword If    not ${clicked}    ${el}=    Get WebElement    ${BTN_EDIT_SINGLE}
    Run Keyword If    not ${clicked}    Execute Javascript    arguments[0].click();    ${el}
    Wait Table Idle

Fill Status Edit And Save
    [Arguments]    ${new_name}
    Wait Until Element Is Visible       ${EDIT_INPUT}    ${TIMEOUT}
    Clear Element Text                  ${EDIT_INPUT}
    Input Text                          ${EDIT_INPUT}    ${new_name}
    Click Element                       ${BTN_SAVE_EDIT}
    Click If Exists                     ${SWAL_CONFIRM}
    Wait Until Element Is Not Visible   ${EDIT_INPUT}    ${TIMEOUT}
    Wait Table Idle

# ===== Utils =====
Click If Exists
    [Arguments]    ${locator}
    ${ok}=    Run Keyword And Return Status    Wait Until Page Contains Element    ${locator}    2s
    Run Keyword If    ${ok}    Click Element    ${locator}
