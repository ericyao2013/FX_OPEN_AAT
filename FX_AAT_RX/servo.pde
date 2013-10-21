/****************************************************

  舵机操作
  Copyright (C) 2013  Coeus Rowe

  @Author 废墟<r.anerg#gmail.com>
  @Link http://anerg.com
  @Date 2013-10-14

  ****************************************************/

float dgree_H = 90.0;
float dgree_V = 90.0;

void move_servo()
{
	float home_lat = (float)home_loc.lat/1000000.0;
	float home_lng = (float)home_loc.lng/1000000.0;
	float cur_lat = (float)current_loc.lat/1000000.0;
	float cur_lng = (float)current_loc.lng/1000000.0;
    float dist = calc_dist(home_lat, home_lng, cur_lat, cur_lng);
	float lat_dist = calc_dist(home_lat, home_lng, cur_lat, home_lng);
	float lng_dist = calc_dist(home_lat, home_lng, home_lat, cur_lng);
	move_servo_H(lat_dist, lng_dist);
    move_servo_V(dist);
}

void move_servo_V(float dist) {
    dgree_V = 90;
	float alt = current_loc.alt - home_loc.alt;
    if(dist > 5) {
	   dgree_V = atan(alt/dist)*180/PI;
    }
	if(current_loc.lat < home_loc.lat || (dgree_H == 0 && current_loc.lng < home_loc.lng)) {
		dgree_V = 180 - dgree_V;
	}
    Serial.print("dgree_V==>");
    Serial.println(dgree_V);

    move_V(dgree_V);
}

void move_servo_H(float lat_dist, float lng_dist) {
    dgree_H = 90;
	if(lat_dist > 0) {
        if((current_loc.lng >= home_loc.lng && current_loc.lat >= home_loc.lat)||(current_loc.lng < home_loc.lng && current_loc.lat < home_loc.lat)) {
            dgree_H -= atan(lng_dist/lat_dist)*180/PI;
        }
        else {
            dgree_H += atan(lng_dist/lat_dist)*180/PI;
        }
	} else {
        dgree_H = 0;
    }
    Serial.print("dgree_H==>");
    Serial.println(dgree_H);

    move_H(dgree_H);
}

void move_H(float dgree) {
    dgree *= 1000;

    dgree = map(dgree, 0, 180000, MIN_PULSE-SERVO_H_LIMIT+SERVO_H_OFFSET, MAX_PULSE+SERVO_H_LIMIT+SERVO_H_OFFSET);
    SERVO_H.writeMicroseconds(dgree);
}
void move_V(float dgree) {
    dgree *= 1000;

    dgree = map(dgree, 0, 180000, MIN_PULSE-SERVO_V_LIMIT+SERVO_V_OFFSET, MAX_PULSE+SERVO_V_LIMIT+SERVO_V_OFFSET);
    SERVO_V.writeMicroseconds(dgree);
}

void init_servo()
{
    move_H(90);
    move_V(90);
    delay(500);
    for (int i = 90; i > 0; i--)
    {
        move_H(i);
        move_V(i);
        delay(10);
    }
    delay(2000);
    for (int i = 0; i < 180; i++)
    {
        move_H(i);
        move_V(i);
        delay(10);
    }
    delay(2000);
    for (int i = 180; i > 90; i--)
    {
        move_H(i);
        move_V(i);
        delay(10);
    }
    move_H(90);
    move_V(90);
}

float calc_dist(float flat1, float flon1, float flat2, float flon2)
{
    float dist_calc = 0;
    float dist_calc2 = 0;
    float diflat = 0;
    float diflon = 0;

    //I've to spplit all the calculation in several steps. If i try to do it in a single line the arduino will explode.
    diflat = radians(flat2 - flat1);
    flat1 = radians(flat1);
    flat2 = radians(flat2);
    diflon = radians((flon2) - (flon1));

    dist_calc = (sin(diflat / 2.0) * sin(diflat / 2.0));
    dist_calc2 = cos(flat1);
    dist_calc2 *= cos(flat2);
    dist_calc2 *= sin(diflon / 2.0);
    dist_calc2 *= sin(diflon / 2.0);
    dist_calc += dist_calc2;

    dist_calc = (2 * atan2(sqrt(dist_calc), sqrt(1.0 - dist_calc)));

    dist_calc *= 6371000.0; //Converting to meters
    //Serial.println(dist_calc);
    return dist_calc;
}


void test_servo() {
    home_loc.lat = 39904030;
    home_loc.lng = 116407526;
    home_loc.alt = 30;

    current_loc.lat = 39913154;
    current_loc.lng = 116407464;
    current_loc.alt = 400;
    Serial.println("Point 1");
    move_servo();
    delay(4000);
    current_loc.lat = 39917242;
    current_loc.lng = 116412968;
    current_loc.alt = 800;
    Serial.println("Point 2");
    move_servo();
    delay(4000);
    current_loc.lat = 39912216;
    current_loc.lng = 116426375;
    current_loc.alt = 600;
    Serial.println("Point 3");
    move_servo();
    delay(4000);
    current_loc.lat = 39902336;
    current_loc.lng = 116429861;
    current_loc.alt = 120;
    Serial.println("Point 4");
    move_servo();
    delay(4000);
    current_loc.lat = 39894643;
    current_loc.lng = 116427246;
    current_loc.alt = 120;
    Serial.println("Point 5");
    move_servo();
    delay(4000);
    current_loc.lat = 39896530;
    current_loc.lng = 116406902;
    current_loc.alt = 120;
    Serial.println("Point 6");
    move_servo();
    delay(4000);
    current_loc.lat = 39889610;
    current_loc.lng = 116396189;
    current_loc.alt = 120;
    Serial.println("Point 7");
    move_servo();
    delay(4000);
    current_loc.lat = 39899645;
    current_loc.lng = 116388378;
    current_loc.alt = 120;
    Serial.println("Point 8");
    move_servo();
    delay(4000);
}