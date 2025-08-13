*** Settings ***
Suite Setup       Open Browser To Login Page
Suite Teardown    Close Browser
Test Setup        Login And Go To Category Page
Resource          ../login_tests/resource.robot
Resource          ./category.robot
Library           random

*** Variables ***
${CATEGORY_BASE}     ทดสอบหมวดหมู่
${TIMEOUT}           10s

*** Test Cases ***
Add Category
    [Documentation]    สร้างหมวดหมู่ใหม่ด้วยชื่อสุ่ม และบันทึกชื่อไว้ใช้ในเคสถัดไป
    ${RANDOM}=         Evaluate    random.randint(1000, 9999)    random
    ${name}=           Set Variable    ${CATEGORY_BASE} ${RANDOM}
    Create Category    ${name}
    Verify Category Exists    ${name}
    Set Suite Variable    ${CREATED_NAME}    ${name}

Edit Category
    [Documentation]    แก้ไขชื่อจาก ${CREATED_NAME} → ${UPDATED_NAME} แล้วตรวจสอบ
    ${old}=            Set Variable    ${CREATED_NAME}
    ${new}=            Set Variable    แก้ไข${old}
    Edit Category      ${old}    ${new}
    Verify Category Exists    ${new}
    Set Suite Variable    ${UPDATED_NAME}    ${new}

Delete Category
    [Documentation]    ลบหมวดหมู่ชื่อ ${UPDATED_NAME} และตรวจสอบว่าไม่เหลือในตาราง
    Delete Category    ${UPDATED_NAME}
    Verify Category Not Exists    ${UPDATED_NAME}

*** Keywords ***
Login And Go To Category Page
    # ไปที่หน้า “หมวดหมู่สินค้า” (ใช้เวอร์ชันที่แชร์)
    Login And Go To Category Page

Open Create Dialog
    Wait Until Element Is Visible    css=button[data-tip="เพิ่มหมวดหมู่"]    ${TIMEOUT}
    Scroll Element Into View         css=button[data-tip="เพิ่มหมวดหมู่"]
    Click Element                    css=button[data-tip="เพิ่มหมวดหมู่"]
    Wait Until Element Is Visible    xpath=//input[@placeholder='ชื่อประเภทสินค้า']    ${TIMEOUT}

Save Category Form
    Click Element                    xpath=//button[contains(text(), 'บันทึกข้อมูล')]
    Wait Until Success Message Appears
    Click Element                    css=button.swal2-confirm

Wait Until Success Message Appears
    Wait Until Element Is Visible    css=.swal2-success    ${TIMEOUT}

# ---------- Add ----------
Create Category
    [Arguments]    ${name}
    Open Create Dialog
    Input Text     xpath=//input[@placeholder='ชื่อประเภทสินค้า']    ${name}
    Save Category Form

# ---------- Edit ----------
Edit Category
    [Arguments]    ${old_name}    ${new_name}
    # ปุ่มแก้ไขในแถวที่มีชื่อเดิม
    ${edit_btn}=   Set Variable    xpath=//td[normalize-space()="${old_name}"]/following-sibling::td//button[@title="แก้ไขหมวดหมู่" or contains(@class,"bg-yellow-100")]
    Wait Until Element Is Visible    ${edit_btn}    ${TIMEOUT}
    Click Element    ${edit_btn}
    Wait Until Element Is Visible    xpath=//input[@placeholder='ชื่อประเภทสินค้า']    ${TIMEOUT}
    Clear Element Text               xpath=//input[@placeholder='ชื่อประเภทสินค้า']
    Input Text                       xpath=//input[@placeholder='ชื่อประเภทสินค้า']    ${new_name}
    Save Category Form

# ---------- Delete ----------
Delete Category
    [Arguments]    ${name}
    ${delete_btn}=   Set Variable    xpath=//td[normalize-space()="${name}"]/following-sibling::td//button[contains(@class,"bg-red-500") or @title="ลบหมวดหมู่"]
    Wait Until Element Is Visible    ${delete_btn}    ${TIMEOUT}
    Scroll Element Into View         ${delete_btn}
    Click Element                    ${delete_btn}

    # ยืนยันลบ (ลองจับทั้งกรณีมีปุ่มข้อความ "ลบ" และปุ่ม swal confirm ธรรมดา)
    ${confirmed}=    Run Keyword And Return Status    Click Element    xpath=//button[contains(@class,"swal2-confirm") and normalize-space()="ลบ"]
    Run Keyword If   not ${confirmed}    Click Element    css=button.swal2-confirm

    Wait Until Success Message Appears
    Click Element                    css=button.swal2-confirm

# ---------- Verify ----------
Verify Category Exists
    [Arguments]    ${name}
    Wait Until Page Contains Element    xpath=//td[normalize-space()="${name}"]    ${TIMEOUT}

Verify Category Not Exists
    [Arguments]    ${name}
    Wait Until Page Does Not Contain Element    xpath=//td[normalize-space()="${name}"]    ${TIMEOUT}
