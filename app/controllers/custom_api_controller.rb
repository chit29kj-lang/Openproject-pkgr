class CustomApiController < ApplicationController
  # 1. ข้ามการตรวจ CSRF Token (เพื่อให้เรียกจาก Postman/External Script ได้)
  # แต่แลกมาด้วยความเสี่ยง ควรใช้เฉพาะ Internal Network หรือใส่ API Key เพิ่ม
  skip_before_action :verify_authenticity_token

  # 2. บังคับว่าต้อง Login และเป็น Admin เท่านั้นถึงจะเปลี่ยน Logo ได้
  before_action :require_admin

  def update_logo
    # รับไฟล์จาก Parameter ที่ชื่อ 'logo_image'
    uploaded_file = params[:logo_image]

    if uploaded_file.nil?
      render json: { status: 'error', message: 'No file uploaded' }, status: 400
      return
    end

    # 3. เรียกใช้ Model 'Design' ของ OpenProject
    # ปกติ OpenProject เก็บ Logo ในตาราง designs
    design = Design.current || Design.new

    # อัปเดต Logo (OpenProject ใช้ CarrierWave หรือ ActiveStorage ในการจัดการไฟล์)
    design.app_logo = uploaded_file

    if design.save
      # 4. Clear Cache เพื่อให้หน้าเว็บเปลี่ยนทันที (สำคัญมาก)
      Rails.cache.clear

      render json: { 
        status: 'success', 
        message: 'Logo updated successfully', 
        url: design.app_logo.url 
      }, status: 200
    else
      render json: { 
        status: 'error', 
        message: design.errors.full_messages 
      }, status: 500
    end
  end
end