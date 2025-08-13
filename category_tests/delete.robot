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

# Create
${BTN_ADD_CATEGORY}   css=button[data-tip='เพิ่มหมวดหมู่']
${CREATE_INPUT}       xpath=//input[@placeholder='ชื่อประเภทสินค้า']
${BTN_SAVE_CREATE}    xpath=//button[contains(normalize-space(.),'บันทึก')]

# Search
${SEARCH_CATEGORY}    id=category-search-input

# Delete (กดปุ่มลบโดยตรงหลังกรอง)
${BTN_DELETE_SINGLE}  css=button[title="ลบ"]

# Misc
${SPINNERS}           css=.ant-spin,.loading,.v-overlay--active
${SWAL_CONFIRM}       css=button.swal2-confirm

*** Test Cases ***
เพิ่มและลบหมวดหมู่
    ${R1}=        Evaluate    random.randint(1000, 9999)    random
    ${name}=      Set Variable    ${CATEGORY_BASE} ${R1}

    Create Category           ${name}
    Apply Search Filter       ${name}
    Click Delete Button
    Confirm Delete Dialog
    Apply Search Filter       ${name}
    Verify Category Not Exists    ${name}

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

# ===== Search (ไม่ assert ว่าต้องพบ) =====
Apply Search Filter
    [Arguments]    ${name}
    Wait Until Element Is Visible    ${SEARCH_CATEGORY}    ${TIMEOUT}
    Press Keys                       ${SEARCH_CATEGORY}    CTRL+A
    Press Keys                       ${SEARCH_CATEGORY}    BACKSPACE
    Input Text                       ${SEARCH_CATEGORY}    ${name}
    Press Keys                       ${SEARCH_CATEGORY}    ENTER
    Wait Table Idle

Wait Table Idle
    Run Keyword And Ignore Error     Wait Until Element Is Not Visible    ${SPINNERS}    5s
    Sleep    0.3s

# ===== Delete (ไม่อิงแถว) =====
Click Delete Button
    Wait Until Page Contains Element    ${BTN_DELETE_SINGLE}    ${TIMEOUT}
    Scroll Element Into View            ${BTN_DELETE_SINGLE}
    ${clicked}=    Run Keyword And Return Status    Click Element    ${BTN_DELETE_SINGLE}
    Run Keyword If    not ${clicked}    ${el}=    Get WebElement    ${BTN_DELETE_SINGLE}
    Run Keyword If    not ${clicked}    Execute Javascript    arguments[0].click();    ${el}

Confirm Delete Dialog
    ${ok}=    Run Keyword And Return Status    Wait Until Page Contains Element    ${SWAL_CONFIRM}    5s
    Run Keyword If    ${ok}    Click Element    ${SWAL_CONFIRM}
    ${ok2}=   Run Keyword And Return Status    Wait Until Page Contains Element    xpath=//button[normalize-space()='ยืนยัน' or normalize-space()='ตกลง' or normalize-space()='OK']    3s
    Run Keyword If    ${ok2}   Click Element    xpath=//button[normalize-space()='ยืนยัน' or normalize-space()='ตกลง' or normalize-space()='OK']
    Wait Table Idle

Verify Category Not Exists
    [Arguments]    ${name}
    Wait Until Page Does Not Contain    ${name}    ${TIMEOUT}

# ===== Utils =====
Click If Exists
    [Arguments]    ${locator}
    ${ok}=    Run Keyword And Return Status    Wait Until Page Contains Element    ${locator}    2s
    Run Keyword If    ${ok}    Click Element    ${locator}
