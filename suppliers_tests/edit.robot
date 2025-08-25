*** Settings ***
Library           SeleniumLibrary
Library           OperatingSystem
Library           random

Suite Setup       Open Browser To Login Page
Suite Teardown    Close All Browsers
Test Setup        Login And Go To Suppliers Page

*** Variables ***
${BASE_URL}           http://localhost:5173
${BROWSER}            chrome
${VALID USER}         admin
${VALID PASSWORD}     12345678
${TIMEOUT}            15s
${SCREEN_DIR}         screenshots

# Locators - Search & Edit
${SEARCH_SUPPLIER}            id=supplier-search-input
${BTN_EDIT_SUPPLIER}          xpath=//button[@title="แก้ไขซัพพลายเออร์" or starts-with(@id,"edit-supplier-button-")]
${INPUT_EDIT_SUPPLIER_NAME}   id=edit-supplier-name-input
${BTN_SAVE_EDIT_SUPPLIER}     id=edit-supplier-submit-button
${SWAL_CONFIRM}               css=button.swal2-confirm
${SPINNERS}                   css=.ant-spin,.loading,.v-overlay--active

*** Test Cases ***
แก้ไขซัพพลายเออร์
    ${old_name}=    Set Variable    ทดสอบซัพพลายเออร์ 1234
    ${new_name}=    Set Variable    ${old_name} แก้ไข

    Search Supplier By Name    ${old_name}
    Click Edit Supplier Button
    Wait Until Element Is Visible    ${INPUT_EDIT_SUPPLIER_NAME}
    Clear Element Text               ${INPUT_EDIT_SUPPLIER_NAME}
    Input Text                       ${INPUT_EDIT_SUPPLIER_NAME}    ${new_name}
    Click Element                    ${BTN_SAVE_EDIT_SUPPLIER}
    Click If Exists                  ${SWAL_CONFIRM}
    Wait Until Element Is Not Visible    ${INPUT_EDIT_SUPPLIER_NAME}    ${TIMEOUT}

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

Click Edit Supplier Button
    Wait Until Page Contains Element    ${BTN_EDIT_SUPPLIER}    ${TIMEOUT}
    Scroll Element Into View            ${BTN_EDIT_SUPPLIER}
    Click Element                       ${BTN_EDIT_SUPPLIER}

Wait Table Idle
    Run Keyword And Ignore Error     Wait Until Element Is Not Visible    ${SPINNERS}    5s
    Sleep    0.3s

Click If Exists
    [Arguments]    ${locator}
    ${ok}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${locator}    2s
    Run Keyword If    ${ok}    Click Element    ${locator}
