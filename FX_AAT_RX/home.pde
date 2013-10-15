/****************************************************
  
  家的地面坐标处理
  Copyright (C) 2013  Coeus Rowe

  @Author 废墟<r.anerg#gmail.com>
  @Link http://anerg.com
  @Date 2013-10-13

****************************************************/

void set_home() {
	char buffer[9];
	int len = 0;

	//纬度
	home_loc.lat = current_loc.lat;
	ltoa(home_loc.lat, buffer, 10);
	len = strlen(buffer);
	for(int i=0; i<9; i++){
		if(len >= 0) {
			EEPROM.write(i, buffer[i]);
		}
		else {
			EEPROM.write(i, 0);
		}
		len--;
	}

	//经度
	home_loc.lng = current_loc.lng;
	ltoa(home_loc.lng, buffer, 10);
	len = strlen(buffer);
	for(int i=0; i<9; i++){
		if(len >= 0) {
			EEPROM.write(i+9, buffer[i]);
		}
		else {
			EEPROM.write(i+9, 0);
		}
		len--;
	}

	//高度
	home_loc.alt = current_loc.alt;
	ltoa(home_loc.alt, buffer, 10);
	len = strlen(buffer);
	for(int i=0; i<9; i++){
		if(len >= 0) {
			EEPROM.write(i+18, buffer[i]);
		}
		else {
			EEPROM.write(i+18, 0);
		}
		len--;
	}
}
void get_home() {
	char buffer[9];
	for(int i=0; i<9; i++) {
		buffer[i] = EEPROM.read(i);
	}
	home_loc.lat = atol(buffer);
	for(int i=0; i<9; i++) {
		buffer[i] = EEPROM.read(i+9);
	}
	home_loc.lng = atol(buffer);
	for(int i=0; i<9; i++) {
		buffer[i] = EEPROM.read(i+18);
	}
	home_loc.alt = atol(buffer);

	if(home_loc.lat != 0 && home_loc.lng != 0 && home_loc.alt != 0) {
		digitalWrite(LED_PIN, LOW);//读取到家的数据，LED熄灭
		HOME_READY = 1;
	}
	else {
		digitalWrite(LED_PIN, HIGH);//未初始化LED常亮
	}

}