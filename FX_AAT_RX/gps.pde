/****************************************************
  
  GPS数据处理
  Copyright (C) 2013  Coeus Rowe

  @Author 废墟<r.anerg#gmail.com>
  @Link http://anerg.com
  @Date 2013-10-13

****************************************************/

String gps_info;//读取的一行gps数据
int gps_info_len;//gps数据的长度
char gps_buf;//单个gps数据字符
int buf_counter = 0;//单个字符计数器
int gps_ready = 0;//标识可读状态
int pos = -1;//字符串查找位置
int part = 0;//gps分段位置
String part_info;//gps分段数据

void get_gps()
{
    if (GPS_UPDATE == 0) {
    	if(read_gps() == 1 && checksum() == 1) {
    		// Serial.println(gps_info);
    		if(gps_info.startsWith("$FX")) {
				parse_GPS();
			}
    	}
    }
}

void parse_GPS() {
	
	do {
		pos = gps_info.indexOf(',');

		if(pos != -1) {
			part_info = gps_info.substring(0, pos);
			part_info.trim();
			gps_info = gps_info.substring(pos+1, gps_info.length());
			
			// switch (part) {
			// 	case 1:
			// 	const char *lat = part_info.c_str();
			// 	current_loc.lat = atol(lat);
			// 	break;
			// 	case 2:
			// 	const char *lng = part_info.c_str();
			// 	current_loc.lng = atol(lng);
			// 	break;
			// 	case 3:
			// 	current_loc.alt = part_info.toInt();
			// 	break;
			// }
			switch (part) {
				case 1:
				current_loc.lat = part_info.toInt();
				break;
				case 2:
				current_loc.lng = part_info.toInt();
				break;
				case 3:
				current_loc.alt = part_info.toInt();
				break;
			}
			part++;
		}
	}
	while(pos >= 0);

	part = 0;
	part_info = "";
	pos = -1;
	GPS_UPDATE = 1;
}

int read_gps() {

	while (modem.available() > 0 && buf_counter < 200) {
		gps_buf = modem.read();
		Serial.print(gps_buf);
		if(gps_buf == '$') {
			gps_ready = 1;
			gps_info = "";
			gps_info_len = 0;
			buf_counter = 0;
		}

		if(gps_ready == 1) {
			gps_info += char(gps_buf);
			if(gps_buf == 0x0A) {
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
            gps_checksum ^= (unsigned char)gps_buffer[x]; //XOR the received data...
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