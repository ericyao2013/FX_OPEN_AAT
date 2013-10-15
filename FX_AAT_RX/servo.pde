/****************************************************

  舵机操作
  Copyright (C) 2013  Coeus Rowe

  @Author 废墟<r.anerg#gmail.com>
  @Link http://anerg.com
  @Date 2013-10-14

  ****************************************************/

int dgree_H = 90;
int dgree_V = 90;

void move_servo()
{
	float home_lat = (float)home_loc.lat/1000000.0;
	float home_lng = (float)home_loc.lng/1000000.0;
	float cur_lat = (float)current_loc.lat/1000000.0;
	float cur_lng = (float)current_loc.lng/1000000.0;
    float dist = calc_dist(home_lat, home_lng, cur_lat, cur_lng)/1000;
    Serial.print("dist ==> ");
    Serial.println(dist);
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

	dgree_V = constrain(dgree_V, 0, 180);
	SERVO_V.write(dgree_V);
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

	dgree_H = constrain(dgree_H, 0, 180);    
	SERVO_H.write(dgree_H);
}

void init_servo()
{
    SERVO_H.write(90);
    SERVO_V.write(90);
    delay(500);
    for (int i = 90; i > 0; i--)
    {
        SERVO_H.write(i);
        SERVO_V.write(i);
        delay(10);
    }
    for (int i = 0; i < 180; i++)
    {
        SERVO_H.write(i);
        SERVO_V.write(i);
        delay(10);
    }
    for (int i = 180; i > 90; i--)
    {
        SERVO_H.write(i);
        SERVO_V.write(i);
        delay(10);
    }
    SERVO_H.write(90);
    SERVO_V.write(90);
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
    home_loc.lat = 30000000;
    home_loc.lng = 30000000;
    home_loc.alt = 3;

    current_loc.lat = 40000000;
    current_loc.lng = 40000000;
    current_loc.alt = 400;
    Serial.println("Point 1");
    move_servo();
    delay(4000);
    current_loc.lat = 30000000;
    current_loc.lng = 40000000;
    current_loc.alt = 800;
    Serial.println("Point 2");
    move_servo();
    delay(4000);
    current_loc.lat = 20000000;
    current_loc.lng = 40000000;
    current_loc.alt = 600;
    Serial.println("Point 3");
    move_servo();
    delay(4000);
    current_loc.lat = 20000000;
    current_loc.lng = 30000000;
    current_loc.alt = 120;
    Serial.println("Point 4");
    move_servo();
    delay(4000);
    current_loc.lat = 20000000;
    current_loc.lng = 20000000;
    current_loc.alt = 120;
    Serial.println("Point 5");
    move_servo();
    delay(4000);
    current_loc.lat = 30000000;
    current_loc.lng = 20000000;
    current_loc.alt = 120;
    Serial.println("Point 6");
    move_servo();
    delay(4000);
    current_loc.lat = 40000000;
    current_loc.lng = 20000000;
    current_loc.alt = 120;
    Serial.println("Point 7");
    move_servo();
    delay(4000);
    current_loc.lat = 40000000;
    current_loc.lng = 30000000;
    current_loc.alt = 120;
    Serial.println("Point 8");
    move_servo();
    delay(4000);
}