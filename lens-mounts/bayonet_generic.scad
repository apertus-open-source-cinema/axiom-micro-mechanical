flange_distance = 20; // distance between mounting surface of the lens and the sensor die (depens on lens / lens mount)
bajonet_radius = 35 / 2; // radius of the inner tube from which the fins extend
fin_height = 2; // height of the fins
fin_radius = bajonet_radius + 2; // radius of the circle formed by the fins
fin_count = 3; // number of fins
fin_ratio = 0.6; // width of fins / width of empty spaces
fin_gap_height = 2; // height of space for the fins of the mount
bajonet_height = 6; // distance between mounting surface and top of the fins
distance_to_sensor_die = 7.5; // distance between the bottom of this adapter and the sensor die
screw_distance = 40; // distance between the screws, that hold the adapter to the camera, assumed to be a square arrangement
screw_diameter = 4;

mount_height = flange_distance - distance_to_sensor_die;
distance_to_fins = mount_height - bajonet_height + fin_height;
$fn = 800;

module mirror2(v) {
	children();
	mirror(v) children();
}

module inverse() {
	difference() {
		square(1e7, center = true);
		children();
	}
}

module fillet(r = 1) {
	inverse() {
		minkowski() {
			circle(r);
			inverse() {
				minkowski() {
					circle(r);
					projection() children();
				}
			}
		}
	}
}

module baseplate() {
	// cube([screw_distance + 5, screw_distance + 5, mount_height], true);
	linear_extrude(center = true, height = mount_height) {
		fillet(r = 3) {
			union() {
				mounting_holes(screw_diameter + 7);
				optical_path(sqrt(screw_distance * screw_distance / 2 - screw_diameter));
			}
			/*
			union() {
				circle(sqrt(screw_distance * screw_distance / 2));
				mirror2([0, 1, 0]) {
					mirror2([1, 0, 0]) {
						translate([screw_distance / 2, screw_distance / 2, 0]) {
							circle(screw_diameter);
						}
					}
				}
			}
			*/
		}
	}
}

//		mounting_holes(screw_diameter + 7);
//		optical_path(sqrt(screw_distance * screw_distance / 2));
//	minkowski() {
//		mounting_holes();
//		circle(r = screw_diameter / 2 + 3);
//		cylinder(r = screw_diameter / 2 + 3, h = 0.1, center = true);
//	}scale(3)

module mounting_screw(screw_diameter) {
	cylinder(h = mount_height, d = screw_diameter, center = true);
}

module mounting_holes(screw_diameter) {
	mirror2([0, 1, 0]) {
		mirror2([1, 0, 0]) {
			translate([screw_distance / 2, screw_distance / 2, 0]) {
				mounting_screw(screw_diameter);
			}
		}
	}
}

module optical_path(radius) {
	cylinder(h = mount_height, r = radius, center = true, $fn = 500);
}


/*
  difference() {
  translate([0, 0, 5]) cylinder(h = 10, d = 30);
  translate([0, 0, 5]) cylinder(h = 30, d = 25);
  }
*/

module fin() {
	union() {
		rotate_extrude(angle = 360 / 6 * fin_ratio) translate([bajonet_radius, 0, 0]) square([fin_radius - bajonet_radius, fin_gap_height], false);
		translate([0, 0, -distance_to_fins]) rotate_extrude(angle = 360 / 6 * fin_ratio * 0.1) translate([bajonet_radius, 0, 0]) square([fin_radius - bajonet_radius, distance_to_fins], false);
	}
}

module fins() {
	for (i = [0:fin_count]) {
		translate([0, 0, distance_to_fins]) rotate([0, 0, 360 / fin_count * i]) fin();
	}
}

union() {
	translate([0, 0, mount_height / 2]) {
		difference() {
			baseplate();
			mounting_holes(screw_diameter);
			optical_path(fin_radius);
		}
	}

	fins();
}
