*** Settings ***
Library           SeleniumLibrary
Library           OperatingSystem
Library           random

Suite Setup       Open Browser To Login Page
Suite Teardown    Close All Browsers
Test Setup        Login And Go To Category Page

*** Variables ***
${BASE_URL}           http://localhost:5173
${BROWSER}            chrome
${VALID USER}         admin
${VALID PASSWORD}     12345678
${CATEGORY_BASE}      ทดสอบหมวดหมู่
${TIMEOUT}            20s
${SCREEN_DIR}         screenshots

# ===== Locators =====
# สร้าง (Create)
${BTN_ADD_CATEGORY}   css=button[data-tip='เพิ่มหมวดหมู่']
${CREATE_INPUT}       xpath=//input[@placeholder='ชื่อประเภทสินค้า']
${BTN_SAVE_CREATE}    xpath=//button[contains(normalize-space(.),'บันทึก')]

# ค้นหา
${SEARCH_CATEGORY}    id=category-search-input

# แก้ไข (Edit)
${BTN_EDIT_SINGLE}    css=button[title="แก้ไขหมวดหมู่"]
${EDIT_INPUT}         id=edit-category-name-input
${BTN_SAVE_EDIT}      xpath=//button[contains(normalize-space(.),'บันทึกข้อมูล')]

# ตัวโหลด/แจ้งเตือน (ถ้ามี)
${SPINNERS}           css=.ant-spin,.loading,.v-overlay--active
${SWAL_CONFIRM}       css=button.swal2-confirm

*** Test Cases ***
เพิ่มและแก้ไขหมวดหมู่ (คลิกปุ่มแก้ไขด้วย title)
    ${R1}=        Evaluate    random.randint(1000, 9999)    random
    ${name}=      Set Variable    ${CATEGORY_BASE} ${R1}

    Create Category                 ${name}
    Search Category By Name         ${name}
    Click Edit Category Button

    ${R2}=        Evaluate    random.randint(1000, 9999)    random
    ${new_name}=  Set Variable    ${name} (แก้ไข ${R2})
    Fill Edit Dialog And Save       ${new_name}

    Search Category By Name         ${new_name}
    Screenshot Row Containing Text  ${new_name}    edited_category.png

*** Keywords ***
Open Browser To Login Page
    Open Browser    ${BASE_URL}    ${BROWSER}
    Maximize Browser Window
    Set Selenium Timeout    ${TIMEOUT}

Login And Go To Category Page
    Wait Until Element Is Visible    css=input[name='username']    ${TIMEOUT}
    Input Text    css=input[name='username']    ${VALID USER}
    Input Text    css=input[name='password']    ${VALID PASSWORD}
    Click Button  css=button[type='submit']
    Wait Until Element Is Visible    xpath=//span[contains(text(),'จัดการ')]    ${TIMEOUT}
    Click Element    xpath=//span[contains(text(),'จัดการ')]
    Click Element    xpath=//a[contains(text(),'ประเภทสินค้า')]
    Wait Until Element Is Visible    ${BTN_ADD_CATEGORY}    ${TIMEOUT}

# ===== Create =====
Create Category
    [Arguments]    ${name}
    Click Element                      ${BTN_ADD_CATEGORY}
    Wait Until Element Is Visible      ${CREATE_INPUT}    ${TIMEOUT}
    Clear Element Text                 ${CREATE_INPUT}
    Input Text                         ${CREATE_INPUT}    ${name}
    Click Element                      ${BTN_SAVE_CREATE}
    Click If Exists                    ${SWAL_CONFIRM}
    Wait Until Element Is Not Visible  ${CREATE_INPUT}    ${TIMEOUT}

# ===== Search =====
Search Category By Name
    [Arguments]    ${name}
    Wait Until Element Is Visible    ${SEARCH_CATEGORY}    ${TIMEOUT}
    Press Keys                       ${SEARCH_CATEGORY}    CTRL+A
    Press Keys                       ${SEARCH_CATEGORY}    BACKSPACE
    Input Text                       ${SEARCH_CATEGORY}    ${name}
    Press Keys                       ${SEARCH_CATEGORY}    ENTER
    Wait Table Idle
    Wait Until Page Contains         ${name}    ${TIMEOUT}

Wait Table Idle
    Run Keyword And Ignore Error     Wait Until Element Is Not Visible    ${SPINNERS}    5s
    Sleep    0.3s

# ===== Edit =====
Click Edit Category Button
    Wait Until Page Contains Element    ${BTN_EDIT_SINGLE}    ${TIMEOUT}
    Scroll Element Into View            ${BTN_EDIT_SINGLE}
    ${clicked}=    Run Keyword And Return Status    Click Element    ${BTN_EDIT_SINGLE}
    Run Keyword If    not ${clicked}    ${el}=    Get WebElement    ${BTN_EDIT_SINGLE}
    Run Keyword If    not ${clicked}    Execute Javascript    arguments[0].click();    ${el}

Fill Edit Dialog And Save
    [Arguments]    ${new_name}
    Wait Until Element Is Visible      ${EDIT_INPUT}    ${TIMEOUT}
    Clear Element Text                 ${EDIT_INPUT}
    Input Text                         ${EDIT_INPUT}    ${new_name}
    Click Element                      ${BTN_SAVE_EDIT}
    Click If Exists                    ${SWAL_CONFIRM}
    Wait Until Element Is Not Visible  ${EDIT_INPUT}    ${TIMEOUT}

# ===== Screenshot =====
Screenshot Row Containing Text
    [Arguments]    ${text}    ${filename}
    ${ROW1}=    Set Variable    xpath=(//tbody//tr[.//*[contains(normalize-space(.),"${text}")]])[1]
    ${has1}=    Run Keyword And Return Status    Page Should Contain Element    ${ROW1}
    ${TARGET}=  Set Variable If    ${has1}    ${ROW1}    xpath=(//*[@role='row'][.//*[contains(normalize-space(.),"${text}")]])[1]
    Wait Until Page Contains Element    ${TARGET}    ${TIMEOUT}
    Scroll Element Into View            ${TARGET}
    Create Directory                    ${SCREEN_DIR}
    Capture Element Screenshot          ${TARGET}    ${SCREEN_DIR}${/}${filename}

# ===== Utils =====
Click If Exists
    [Arguments]    ${locator}
    ${ok}=    Run Keyword And Return Status    Wait Until Page Contains Element    ${locator}    2s
    Run Keyword If    ${ok}    Click Element    ${locator}
