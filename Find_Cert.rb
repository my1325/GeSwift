require 'spaceship'

Spaceship.login('1173962595@qq.com') #输入对应的苹果账号
Spaceship.select_team
# ('GY929GT648')

Spaceship.certificate.all.each do |cert| 
  cert_type = Spaceship::Portal::Certificate::CERTIFICATE_TYPE_IDS[cert.type_display_id].to_s.split("::")[-1]
  puts "Cert id: #{cert.id}, name: #{cert.name}, expires: #{cert.expires.strftime("%Y-%m-%d")}, type: #{cert_type}"
end
