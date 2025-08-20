*** Settings ***
Library           SeleniumLibrary
Library           OperatingSystem

Suite Setup       Open Browser To Login Page
Suite Teardown    Close All Browsers
Test Setup        Login And Go To Profile

*** Variables ***
${BASE_URL}                 http://localhost:5173
${BROWSER}                  chrome
${VALID USER}               admin1
${VALID PASSWORD}           12345678
${TIMEOUT}                  20s
${SCREEN_DIR}               screenshots

# Page & Menu
${PROFILE_URL}              ${BASE_URL}/profile
${PROFILE_DROPDOWN_BTN}     xpath=//div[contains(@class,'dropdown')]/button[contains(@class,'btn-ghost')]
${BTN_GO_SETTINGS}          xpath=//button[contains(normalize-space(.),'การตั้งค่า')]

# Edit Profile
${BTN_PROFILE_EDIT}         id=profile-edit-button
${AVATAR_CLICK_AREA}        id=edit-profile-avatar
# ตัวเลือก input[type=file] ที่มักพบ (เลือกอันแรกที่เจอ)
${AVATAR_INPUT_OPT1}        xpath=//input[@type='file' and (contains(@id,'avatar') or contains(@name,'avatar'))]
${AVATAR_INPUT_OPT2}        xpath=//input[@type='file' and contains(@accept,'image')]
${AVATAR_INPUT_OPT3}        xpath=//div[@id='edit-profile-avatar']//input[@type='file']

${BTN_SUBMIT}               id=edit-profile-submit-button

# Misc
${SPINNERS}                 css=.ant-spin,.loading,.v-overlay--active,.swal2-container
${SWAL_CONFIRM}             css=button.swal2-confirm

# ไฟล์รูปที่จะอัปโหลด (แก้พาธนี้ให้ตรงเครื่องคุณ)
${AVATAR_FILEPATH}          E:${/}มหาลัย${/}โปรเจค${/}Robot_Pos${/}photo${/}v3_0039338.jpg

*** Test Cases ***
เปลี่ยนรูปโปรไฟล์ (อัปโหลดรูป) — ถ่ายภาพทุกขั้นตอน
    [Documentation]    ล็อกอิน → /profile → เมนูการตั้งค่า → แก้ไขข้อมูลส่วนตัว → อัปโหลดรูป → บันทึก
    Create Directory                    ${SCREEN_DIR}

    # 1) เปิดหน้าโปรไฟล์
    Go To                               ${PROFILE_URL}
    Wait Table Idle
    Capture Page Screenshot             ${SCREEN_DIR}${/}profile_page.png

    # 2) เปิดเมนู “การตั้งค่า”
    Wait Until Element Is Visible       ${PROFILE_DROPDOWN_BTN}    ${TIMEOUT}
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
    Capture Page Screenshot             ${SCREEN_DIR}${/}profile_edit_open.png

    # 4) อัปโหลดรูปใหม่
    Upload Avatar From Path             ${AVATAR_FILEPATH}
    # ถ่ายภาพหลังเลือกรูป (ตัวพรีวิวมักจะเปลี่ยน)
    Capture Page Screenshot             ${SCREEN_DIR}${/}profile_avatar_selected.png

    # 5) บันทึก
    Scroll Element Into View            ${BTN_SUBMIT}
    Click Element                       ${BTN_SUBMIT}
    Click If Exists                     ${SWAL_CONFIRM}
    Wait Table Idle
    Capture Page Screenshot             ${SCREEN_DIR}${/}profile_avatar_saved.png


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
    # ให้แน่ใจว่ามี dropdown โปรไฟล์ให้กด
    Wait Until Element Is Visible    ${PROFILE_DROPDOWN_BTN}    ${TIMEOUT}

Upload Avatar From Path
    [Arguments]    ${filepath}
    # คลิกกรอบรูปก่อน เผื่อ UI สร้าง input[file] ตอนคลิก
    Wait Until Element Is Visible       ${AVATAR_CLICK_AREA}    ${TIMEOUT}
    Scroll Element Into View            ${AVATAR_CLICK_AREA}
    Click Element                       ${AVATAR_CLICK_AREA}
    Sleep    0.3s

    # หา input[type=file] ตัวแรกที่เจอจากลิสต์ที่เตรียมไว้
    ${file_input}=    Get First Present Locator    ${AVATAR_INPUT_OPT1}    ${AVATAR_INPUT_OPT2}    ${AVATAR_INPUT_OPT3}
    # บางที input ถูกซ่อนไว้ ให้เปิดด้วย JS ให้คลิก/เลือกไฟล์ได้ (Choose File ใช้ได้แม้ hidden แต่กันเหนียว)
    Run Keyword And Ignore Error    Execute Javascript    arguments[0].style.display='block';    ${file_input}
    Run Keyword And Ignore Error    Execute Javascript    arguments[0].removeAttribute('hidden');    ${file_input}

    # ใส่ไฟล์ลง input[type=file]
    Choose File                       ${file_input}    ${filepath}
    Wait Table Idle
    # เผื่อมีการอัปโหลดขึ้น preview ให้รอสั้น ๆ
    Sleep    0.7s

Get First Present Locator
    [Arguments]    @{locators}
    FOR    ${loc}    IN    @{locators}
        ${ok}=    Run Keyword And Return Status    Page Should Contain Element    ${loc}
        IF    ${ok}    RETURN    ${loc}
    END
    Fail    ไม่พบ input[type=file] สำหรับอัปโหลดรูปโปรไฟล์ (ลองคลิกกรอบรูปแล้วแล้วยังไม่เจอ)

Wait Table Idle
    Run Keyword And Ignore Error     Wait Until Element Is Not Visible    ${SPINNERS}    6s
    Sleep    0.3s

Click If Exists
    [Arguments]    ${locator}
    ${ok}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${locator}    3s
    Run Keyword If    ${ok}    Click Element    ${locator}
