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

# Locators - Buttons & Inputs
${BTN_ADD_SUPPLIER}           id=create-supplier-button
${INPUT_SUPPLIER_NAME}        id=create-supplier-name-input
${INPUT_SUPPLIER_CONTACT}     id=create-supplier-contact-input
${INPUT_SUPPLIER_PHONE}       id=create-supplier-phone-input
${INPUT_SUPPLIER_ADDRESS}     id=create-supplier-address-input
${BTN_SAVE_SUPPLIER}          id=create-supplier-submit-button
${SEARCH_SUPPLIER}            id=supplier-search-input
${SPINNERS}                   css=.ant-spin,.loading,.v-overlay--active
${SWAL_CONFIRM}               css=button.swal2-confirm

*** Test Cases ***
เพิ่มซัพพลายเออร์
    ${RANDOM}=    Evaluate    random.randint(1000, 9999)    random
    ${name}=      Set Variable    ทดสอบซัพพลายเออร์ ${RANDOM}
    ${contact}=   Set Variable    คุณสมชาย
    ${phone}=     Set Variable    0812345678
    ${address}=   Set Variable    123/45 ถนนทดสอบ เขตทดสอบ กรุงเทพฯ

    Click Element                 ${BTN_ADD_SUPPLIER}
    Create Supplier Full Form     ${name}    ${contact}    ${phone}    ${address}
    Search Supplier By Name       ${name}
    Screenshot Latest Supplier Row    ${name}

*** Keywords ***
# ===== Browser & Login =====
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
    Wait Until Element Is Visible    ${BTN_ADD_SUPPLIER}

# ===== Create Supplier =====
Create Supplier Full Form
    [Arguments]    ${name}    ${contact}    ${phone}    ${address}
    Wait Until Element Is Visible    ${INPUT_SUPPLIER_NAME}    ${TIMEOUT}
    Clear Element Text               ${INPUT_SUPPLIER_NAME}
    Input Text                       ${INPUT_SUPPLIER_NAME}    ${name}

    Wait Until Element Is Visible    ${INPUT_SUPPLIER_CONTACT}    ${TIMEOUT}
    Clear Element Text               ${INPUT_SUPPLIER_CONTACT}
    Input Text                       ${INPUT_SUPPLIER_CONTACT}    ${contact}

    Wait Until Element Is Visible    ${INPUT_SUPPLIER_PHONE}    ${TIMEOUT}
    Clear Element Text               ${INPUT_SUPPLIER_PHONE}
    Input Text                       ${INPUT_SUPPLIER_PHONE}    ${phone}

    Wait Until Element Is Visible    ${INPUT_SUPPLIER_ADDRESS}    ${TIMEOUT}
    Clear Element Text               ${INPUT_SUPPLIER_ADDRESS}
    Input Text                       ${INPUT_SUPPLIER_ADDRESS}    ${address}

    Click Element                    ${BTN_SAVE_SUPPLIER}
    Click If Exists                  ${SWAL_CONFIRM}
    Wait Until Element Is Not Visible    ${INPUT_SUPPLIER_NAME}    ${TIMEOUT}

# ===== Search Supplier =====
Search Supplier By Name
    [Arguments]    ${name}
    Wait Until Element Is Visible    ${SEARCH_SUPPLIER}    ${TIMEOUT}
    Clear Element Text               ${SEARCH_SUPPLIER}
    Input Text                       ${SEARCH_SUPPLIER}    ${name}
    Press Keys                       ${SEARCH_SUPPLIER}    ENTER
    Wait Table Idle
    Wait Until Page Contains         ${name}    ${TIMEOUT}

# ===== Screenshot Supplier Row =====
Screenshot Latest Supplier Row
    [Arguments]    ${name}
    ${ROW}=    Set Variable    xpath=(//tr[.//*[self::td or self::span or self::div][contains(normalize-space(.),"${name}")]])[1]
    Wait Until Element Is Visible    ${ROW}    ${TIMEOUT}
    Scroll Element Into View         ${ROW}
    Create Directory    ${SCREEN_DIR}
    Capture Element Screenshot    ${ROW}    ${SCREEN_DIR}${/}latest_supplier.png

# ===== Utils =====
Wait Table Idle
    Run Keyword And Ignore Error     Wait Until Element Is Not Visible    ${SPINNERS}    5s
    Sleep    0.3s

Click If Exists
    [Arguments]    ${locator}
    ${ok}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${locator}    2s
    Run Keyword If    ${ok}    Click Element    ${locator}
