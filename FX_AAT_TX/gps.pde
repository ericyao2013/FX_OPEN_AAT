/****************************************************
  
  GPS数据处理
  Copyright (C) 2013  Coeus Rowe

  @Author 废墟<r.anerg#gmail.com>
  @Link http://anerg.com
  @Date 2013-10-11

****************************************************/

String gps_info;//串口读取的一行gps数据
int gps_info_len;//gps数据的长度
char gps_buf;//单个gps数据字符
int buf_counter = 0;//单个字符计数器
int gps_ready = 0;//标识可读状态
int pos = -1;//字符串查找位置
int part = 0;//gps分段位置
String part_info;//gps分段数据

void get_gps() {

	if (GPS_UPDATE == 0) {
		if(read_gps() == 1 && checksum() == 1) {
			if(gps_info.startsWith("$GPRMC")) {
				parse_GPRMC();
			}
			if(gps_info.startsWith("$GPGGA")) {
				parse_GPGGA();
			}

			gps_info = "";
			if(GPS_UPDATE == 1) {
				build_MSG();
			}

		}
	}
}

void send_test() {
	MSG = "$FX,31800785,121634401,0,*18";
	send_gps();
}

void send_gps() {
	// modem.write(0xFF);
	for(int i=0; i<MSG.length(); i++){
		modem.write(char(MSG[i]));
	}
	modem.write(char(0X0A));
	GPS_UPDATE = 0;
}

void build_MSG() {
	MSG = "$FX,";
	MSG += current_loc.lat;
	MSG += ",";
	MSG += current_loc.lng;
	MSG += ",";
	MSG += current_loc.alt;
	MSG += ",";
	int c = 0, XOR = 0;
	for (int i = 1; i < MSG.length(); i++)
	{
		c = (unsigned char)MSG[i];
		XOR ^= c;
	}
	MSG += "*";
	MSG += String(XOR, HEX);
	Serial.println(MSG);
}

void parse_GPRMC() {
	
	do {
		pos = gps_info.indexOf(',');

		if(pos != -1) {
			part_info = gps_info.substring(0, pos);
			part_info.trim();
			gps_info = gps_info.substring(pos+1, gps_info.length());
			
			switch (part) {
				case 2:
				if(part_info.charAt(0) == 'A') {
					GPS_UPDATE = 1;
				}
				break;
				case 3:
				current_loc.lat = parse_data(part_info);
				break;
				case 4:
				if(part_info.charAt(0) == 'S') {
					current_loc.lat *= -1;
				}
				break;
				case 5:
				current_loc.lng = parse_data(part_info);
				break;
				case 6:
				if(part_info.charAt(0) == 'W') {
					current_loc.lng *= -1;
				}
				break;
			}
			part++;
		}
	}
	while(pos >= 0);

	part = 0;
	String part_info = "";
	pos = -1;
}

void parse_GPGGA() {

	do {
		pos = gps_info.indexOf(',');
		if(pos != -1) {
			part_info = gps_info.substring(0, pos);
			gps_info = gps_info.substring(pos+1, gps_info.length());
			switch (part) {
				case 2:
				current_loc.lat = parse_data(part_info);
				break;
				case 3:
				if(part_info.charAt(0) == 'S') {
					current_loc.lat *= -1;
				}
				break;
				case 4:
				current_loc.lng = parse_data(part_info);
				break;
				case 5:
				if(part_info.charAt(0) == 'W') {
					current_loc.lng *= -1;
				}
				break;
				case 6:
				if(part_info.toInt() > 0) {
					GPS_UPDATE = 1;
				}
				break;
				case 9:
				current_loc.alt = (long)abs(part_info.toInt());
				break;
			}
			part++;
		}
	}
	while(pos >= 0);

	part = 0;
	String part_info = "";
	pos = -1;
}

/* 解析经纬度数据 */
long parse_data(String info)
{
	char *brk_loc;
	int info_len = info.length();
	char data[info_len];
	info.toCharArray(data, info_len);
	unsigned long degree = 0;
	unsigned long minute = 0;
	degree = strtol (data, &brk_loc, 10) / 100;
	minute = (((atol(data) % 100) * 10000 + strtol(brk_loc + 1, NULL, 10)) * 10) / 6;
	return degree * 1000000 + minute;
}

int read_gps() {

	while (Serial.available() > 0 && buf_counter < 200) {
		gps_buf = Serial.read();

		if(gps_buf == '$') {
			gps_ready = 1;
			gps_info = "";
			gps_info_len = 0;
			buf_counter = 0;
		}

		if(gps_ready == 1) {
			gps_info += char(gps_buf);
			if(gps_buf == '\n' || gps_buf == '\r') {
				gps_info_len = gps_info.length();
				buf_counter = 0;
				gps_ready = 0;
				return 1;
			}
		}
		buf_counter++;
	}
	return 0;
}


int checksum()
{
	char gps_buffer[gps_info_len];
	gps_info.toCharArray(gps_buffer, gps_info_len);
	byte gps_checksum = 0;
	byte gps_checksum_received = 0;
	for (int x = 1; x < gps_info_len; x++)
	{
		if (gps_buffer[x] == '*')
		{
            gps_checksum_received = strtol(&gps_buffer[x + 1], NULL, 16);//Parsing received checksum...
            break;
        }
        else
        {
            gps_checksum ^= gps_buffer[x]; //XOR the received data...
        }
    }

    if (gps_checksum == gps_checksum_received)
    {
    	return 1;
    }
    else
    {
    	return 0;
    }
}