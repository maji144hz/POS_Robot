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
${CATEGORY_BASE}      ทดสอบสถานะ
${TIMEOUT}            15s
${SCREEN_DIR}         screenshots

# Locators
${BTN_ADD_CATEGORY}   xpath=//button[contains(@class, 'filter-button')]//span[contains(text(), 'เพิ่มสถานะสินค้า')]
${INPUT_CATEGORY}     xpath=//input[@placeholder='ชื่อสถานะสินค้า']
${BTN_SAVE}           xpath=//button[contains(normalize-space(.),'บันทึก')]
${SEARCH_CATEGORY}    id=status-search-input

*** Test Cases ***
เพิ่มหมวดหมู่
    ${RANDOM}=    Evaluate    random.randint(1000, 9999)    random
    ${name}=      Set Variable    ${CATEGORY_BASE} ${RANDOM}
    Create Category           ${name}
    Search Category By Name   ${name}
    Screenshot Latest Category Row    ${name}

*** Keywords ***
Open Browser To Login Page
    Open Browser    ${BASE_URL}    ${BROWSER}
    Maximize Browser Window
    Set Selenium Timeout    ${TIMEOUT}

Login And Go To Category Page
    Wait Until Element Is Visible    css=input[name='username']
    Input Text    css=input[name='username']    ${VALID USER}
    Input Text    css=input[name='password']    ${VALID PASSWORD}
    Click Button  css=button[type='submit']
    Wait Until Element Is Visible    xpath=//span[contains(text(),'จัดการ')]
    Click Element    xpath=//span[contains(text(),'จัดการ')]
    Click Element    xpath=//a[contains(text(),' จัดการสถานะสินค้า')]
    Wait Until Element Is Visible    ${BTN_ADD_CATEGORY}

Create Category
    [Arguments]    ${name}
    Click Element    ${BTN_ADD_CATEGORY}
    Wait Until Element Is Visible    ${INPUT_CATEGORY}
    Clear Element Text    ${INPUT_CATEGORY}
    Input Text            ${INPUT_CATEGORY}    ${name}
    Click Element         ${BTN_SAVE}
    Click If Exists       css=button.swal2-confirm
    Wait Until Element Is Not Visible    ${INPUT_CATEGORY}    ${TIMEOUT}

Search Category By Name
    [Arguments]    ${name}
    Wait Until Element Is Visible    ${SEARCH_CATEGORY}    ${TIMEOUT}
    Clear Element Text    ${SEARCH_CATEGORY}
    Input Text            ${SEARCH_CATEGORY}    ${name}
    Press Keys            ${SEARCH_CATEGORY}    ENTER
    Wait Until Page Contains    ${name}    ${TIMEOUT}

Screenshot Latest Category Row
    [Arguments]    ${name}
    ${ROW}=    Set Variable    xpath=(//tr[.//*[self::td or self::span or self::div][contains(normalize-space(.),"${name}")]])[1]
    Wait Until Element Is Visible    ${ROW}    ${TIMEOUT}
    Scroll Element Into View         ${ROW}
    Create Directory    ${SCREEN_DIR}
    Capture Element Screenshot    ${ROW}    ${SCREEN_DIR}${/}latest_category.png

Click If Exists
    [Arguments]    ${locator}
    ${ok}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${locator}    2s
    Run Keyword If    ${ok}    Click Element    ${locator}
