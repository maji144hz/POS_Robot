*** Settings ***
Library           SeleniumLibrary
Library           OperatingSystem

Suite Setup       Open Browser To Login Page
Suite Teardown    Close All Browsers
Test Setup        Login And Go To Suppliers Page

*** Variables ***
${BASE_URL}           http://localhost:5173
${BROWSER}            chrome
${VALID USER}         admin
${VALID PASSWORD}     12345678
${TIMEOUT}            15s
${SEARCH_SUPPLIER}    id=supplier-search-input
${BTN_DELETE_SUPPLIER} xpath=//button[@title="ลบซัพพลายเออร์" or starts-with(@id,"delete-supplier-button-")]
${SWAL_CONFIRM}       css=button.swal2-confirm
${SPINNERS}           css=.ant-spin,.loading,.v-overlay--active

*** Test Cases ***
ลบซัพพลายเออร์
    ${name}=    Set Variable    ทดสอบซัพพลายเออร์ 1234
    Search Supplier By Name    ${name}
    Click Delete Supplier Button
    Confirm Delete Dialog
    Search Supplier By Name    ${name}
    Verify Supplier Not Exists    ${name}

*** Keywords ***
Open Browser To Login Page
    Open Browser    ${BASE_URL}    ${BROWSER}
    Maximize Browser Window
    Set Selenium Timeout    ${TIMEOUT}

Login And Go To Suppliers Page
    Wait Until Element Is Visible    css=input[name='username']
    Input Text    css=input[name='username']    ${VALID USER}
    Input Text    css=input[name='password']    ${VALID PASSWORD}
    Click Button  css=button[type='submit']
    Wait Until Element Is Visible    xpath=//span[contains(text(),'จัดการ')]
    Click Element    xpath=//span[contains(text(),'จัดการ')]
    Click Element    xpath=//a[contains(text(),'จัดการซัพพลายเออร์')]
    Wait Until Element Is Visible    ${SEARCH_SUPPLIER}

Search Supplier By Name
    [Arguments]    ${name}
    Wait Until Element Is Visible    ${SEARCH_SUPPLIER}    ${TIMEOUT}
    Clear Element Text               ${SEARCH_SUPPLIER}
    Input Text                       ${SEARCH_SUPPLIER}    ${name}
    Press Keys                       ${SEARCH_SUPPLIER}    ENTER
    Wait Table Idle

Click Delete Supplier Button
    Wait Until Page Contains Element    ${BTN_DELETE_SUPPLIER}    ${TIMEOUT}
    Scroll Element Into View            ${BTN_DELETE_SUPPLIER}
    Click Element                       ${BTN_DELETE_SUPPLIER}
    Wait Table Idle

Confirm Delete Dialog
    ${ok}=    Run Keyword And Return Status    Wait Until Page Contains Element    ${SWAL_CONFIRM}    5s
    Run Keyword If    ${ok}    Click Element    ${SWAL_CONFIRM}
    ${ok2}=   Run Keyword And Return Status    Wait Until Page Contains Element    xpath=//button[normalize-space()='ยืนยัน' or normalize-space()='ตกลง' or normalize-space()='OK']    3s
    Run Keyword If    ${ok2}   Click Element    xpath=//button[normalize-space()='ยืนยัน' or normalize-space()='ตกลง' or normalize-space()='OK']
    Wait Table Idle

Verify Supplier Not Exists
    [Arguments]    ${name}
    Wait Until Page Does Not Contain    ${name}    ${TIMEOUT}

Wait Table Idle
    Run Keyword And Ignore Error     Wait Until Element Is Not Visible    ${SPINNERS}    5s
    Sleep    0.3s
