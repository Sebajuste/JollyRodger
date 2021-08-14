class_name Balistic

const eps : float = 1e-9
const FLOAT_EPSILON = 0.00001


static func is_equal(a : float, b : float, epsilon = FLOAT_EPSILON) -> bool:
	
	return abs(a - b) <= epsilon
	

static func is_zero(d : float) -> bool:
	
	#return d == 0.0 or (d > -eps and d < eps)
	return is_equal(d, 0.0)
	


static func get_cubic_root(value : float) -> float:
	if value > 0.0:
		return pow(value, 1.0 / 3.0)
	elif value < 0:
		return -pow(-value, 1.0 / 3.0)
	else:
		return 0.0


static func solve_quadric(c0 : float, c1 : float, c2 : float, s : Array) -> int:
	s.resize(2)
	s[0] = 0.0
	s[1] = 0.0
	#s0 = double.NaN;
	#s1 = double.NaN;
	
	#double p, q, D;
	
	#/* normal form: x^2 + px + q = 0 */
	var p : float = c1 / (2.0 * c0)
	var q : float = c2 / c0
	
	var D : float = p * p - q
	
	if is_zero(D):
		s[0] = -p
		return 1
	elif D < 0:
		return 0
	else:
		var sqrt_D := sqrt(D)
		s[0] = sqrt_D - p
		s[1] = -sqrt_D - p
		return 2


static func solve_cubic(c0 : float, c1 : float, c2 : float, c3 : float, s : Array) -> int:
	s.resize(3)
	
	var num := 0
	
	#/* normal form: x^3 + Ax^2 + Bx + C = 0 */
	var A := c1 / c0
	var B := c2 / c0
	var C := c3 / c0
	
	#/*  substitute x = y - A/3 to eliminate quadric term:  x^3 +px + q = 0 */
	var sq_A := A * A;
	var p := 1.0/3 * (- 1.0/3 * sq_A + B);
	var q := 1.0/2 * (2.0/27 * A * sq_A - 1.0/3 * A * B + C);
	
	#/* use Cardano's formula */
	var cb_p := p * p * p;
	var D := q * q + cb_p;
	
	if is_zero(D):
		if is_zero(q): #) /* one triple solution */ {
			s[0] = 0
			num = 1;
		else: # /* one single and one double solution */ {
			var u := get_cubic_root(-q)
			s[0] = 2 * u
			s[1] = - u
			num = 2
	elif D < 0: # /* Casus irreducibilis: three real solutions */ {
		var phi := 1.0/3 * acos(-q / sqrt(-cb_p))
		var t := 2 * sqrt(-p)
		
		s[0] = t * cos(phi)
		s[1] = - t * cos(phi + PI / 3)
		s[2] = - t * cos(phi - PI / 3)
		num = 3
	else: # /* one real solution */ {
		var sqrt_D = sqrt(D);
		var u := get_cubic_root(sqrt_D - q)
		var v := -get_cubic_root(sqrt_D + q)
		s[0] = u + v
		num = 1
		
	#/* resubstitute */
	var sub := 1.0/3.0 * A
	
	if (num > 0):
		s[0] -= sub
	if (num > 1):
		s[1] -= sub
	if (num > 2):
		s[2] -= sub
	
	return num





static func solve_quartic(c0 : float, c1 : float, c2 : float, c3 : float, c4 : float, s : Array) -> int:
	
	s.resize(4)
	s[0] = NAN
	s[1] = NAN
	s[2] = NAN
	s[3] = NAN
	"""
	s0 = double.NaN
	s1 = double.NaN;
	s2 = double.NaN;
	s3 = double.NaN;
	"""
	
	var s_temp := Array()
	
	#double[] coeffs = new double[4];
	var coeffs := [0, 0, 0, 0]
	var z := 0.0
	var u := 0.0
	var v := 0.0
	var sub := 0.0
	
	var num := 0
	
	#/* normal form: x^4 + Ax^3 + Bx^2 + Cx + D = 0 */
	var A := c1 / c0
	var B := c2 / c0
	var C := c3 / c0
	var D := c4 / c0
	
	#/*  substitute x = y - A/4 to eliminate cubic term: x^4 + px^2 + qx + r = 0 */
	var sq_A := A * A
	var p := - 3.0/8.0 * sq_A + B
	var q := 1.0/8.0 * sq_A * A - 1.0/2.0 * A * B + C
	var r := - 3.0/256.0*sq_A*sq_A + 1.0/16.0*sq_A*B - 1.0/4.0*A*C + D
	
	if is_zero(r):
		#/* no absolute term: y(y^3 + py + q) = 0 */
		
		print("is zero z")
		
		coeffs[ 3 ] = q;
		coeffs[ 2 ] = p;
		coeffs[ 1 ] = 0;
		coeffs[ 0 ] = 1;
		
		s_temp.resize(3)
		s_temp[0] = s[0]
		s_temp[1] = s[1]
		s_temp[2] = s[2]
		num = solve_cubic(coeffs[0], coeffs[1], coeffs[2], coeffs[3], s_temp);
		s[0] = s_temp[0]
		s[1] = s_temp[1]
		s[2] = s_temp[2]
	else:
		
		#/* solve the resolvent cubic ... */
		coeffs[ 3 ] = 1.0/2 * r * p - 1.0/8 * q * q
		coeffs[ 2 ] = - r
		coeffs[ 1 ] = - 1.0/2 * p
		coeffs[ 0 ] = 1
		
		s_temp.resize(3)
		s_temp[0] = s[0]
		s_temp[1] = s[1]
		s_temp[2] = s[2]
		var _r := solve_cubic(coeffs[0], coeffs[1], coeffs[2], coeffs[3], s_temp);
		s[0] = s_temp[0]
		s[1] = s_temp[1]
		s[2] = s_temp[2]
		
		#/* ... and take the one real solution ... */
		z = s[0]
		
		#/* ... to build two quadric equations */
		u = z * z - r
		v = 2 * z - p
		
		if is_zero(u):
			u = 0
		elif u > 0:
			u = sqrt(u)
		else:
			return 0
		
		if is_zero(v):
			v = 0
		elif v > 0:
			v = sqrt(v)
		else:
			return 0
		
		coeffs[ 2 ] = z - u
		coeffs[ 1 ] = -v if q < 0 else v
		coeffs[ 0 ] = 1
		s_temp.resize(2)
		s_temp[0] = s[0]
		s_temp[1] = s[1]
		num = solve_quadric(coeffs[0], coeffs[1], coeffs[2], s_temp)
		s[0] = s_temp[0]
		s[1] = s_temp[1]
		coeffs[ 2 ] = z + u
		coeffs[ 1 ] = v if q < 0 else -v
		coeffs[ 0 ] = 1
		
		if (num == 0):
			s_temp.resize(2)
			s_temp[0] = s[1]
			s_temp[1] = s[2]
			num += solve_quadric(coeffs[0], coeffs[1], coeffs[2], s_temp)
			s[1] = s_temp[0]
			s[2] = s_temp[1]
		elif (num == 1):
			s_temp.resize(2)
			s_temp[0] = s[1]
			s_temp[1] = s[2]
			num += solve_quadric(coeffs[0], coeffs[1], coeffs[2], s_temp)
			s[1] = s_temp[0]
			s[2] = s_temp[1]
		elif (num == 2):
			s_temp.resize(2)
			s_temp[0] = s[2]
			s_temp[1] = s[3]
			num += solve_quadric(coeffs[0], coeffs[1], coeffs[2], s_temp)
			s[2] = s_temp[0]
			s[3] = s_temp[1]
	
	#/* resubstitute */
	sub = 1.0/4.0 * A
	
	if (num > 0):
		s[0] -= sub
	if (num > 1):
		s[1] -= sub
	if (num > 2):
		s[2] -= sub
	if (num > 3):
		s[3] -= sub
	
	return num
	





static func max_range(speed : float, gravity : float, initial_height : float) -> float:
	
	# Handling these cases is up to your project's coding standards
	assert(speed > 0 && gravity > 0 && initial_height >= 0, "fts.ballistic_range called with invalid data")
	
	# Derivation
	# (1) x = speed * time * cos O
	# (2) y = initial_height + (speed * time * sin O) - (.5 * gravity*time*time)
	# (3) via quadratic: t = (speed*sin O)/gravity + sqrt(speed*speed*sin O + 2*gravity*initial_height)/gravity    [ignore smaller root]
	# (4) solution: range = x = (speed*cos O)/gravity * sqrt(speed*speed*sin O + 2*gravity*initial_height)    [plug t back into x=speed*time*cos O]
	
	var angle : float = deg2rad( 45 ) # no air resistence, so 45 degrees provides maximum range
	var c : float = cos(angle);
	var s : float = sin(angle);
	
	var max_range : float = (speed * c / gravity) * (speed * s + sqrt(speed * speed * s * s + 2 * gravity * initial_height))
	return max_range



static func solve_ballistic_arc(proj_pos : Vector3, proj_speed : float, target : Vector3, gravity : float = 9.8) -> Vector3:
	
	# Handling these cases is up to your project's coding standards
	assert(proj_pos != target && proj_speed > 0 && gravity > 0, "fts.solve_ballistic_arc called with invalid data");
	
	# C# requires out variables be set
	var s0 := Vector3.ZERO;
	var _s1 := Vector3.ZERO;
	
	# Derivation
	#   (1) x = v*t*cos O
	#   (2) y = v*t*sin O - .5*g*t^2
	#
	#   (3) t = x/(cos O*v)                                        [solve t from (1)]
	#   (4) y = v*x*sin O/(cos O * v) - .5*g*x^2/(cos^2 O*v^2)     [plug t into y=...]
	#   (5) y = x*tan O - g*x^2/(2*v^2*cos^2 O)                    [reduce; cos/sin = tan]
	#   (6) y = x*tan O - (g*x^2/(2*v^2))*(1+tan^2 O)              [reduce; 1+tan O = 1/cos^2 O]
	#   (7) 0 = ((-g*x^2)/(2*v^2))*tan^2 O + x*tan O - (g*x^2)/(2*v^2) - y    [re-arrange]
	#   Quadratic! a*p^2 + b*p + c where p = tan O
	#
	#   (8) let gxv = -g*x*x/(2*v*v)
	#   (9) p = (-x +- sqrt(x*x - 4gxv*(gxv - y)))/2*gxv           [quadratic formula]
	#   (10) p = (v^2 +- sqrt(v^4 - g(g*x^2 + 2*y*v^2)))/gx        [multiply top/bottom by -2*v*v/x; move 4*v^4/x^2 into root]
	#   (11) O = atan(p)
	
	var diff := target - proj_pos
	var diffXZ := Vector3(diff.x, 0.0, diff.z)
	var groundDist := diffXZ.length()
	
	var speed2 := proj_speed*proj_speed
	var speed4 := proj_speed*proj_speed*proj_speed*proj_speed
	var y := diff.y
	var x := groundDist
	var gx := gravity*x
	
	var root := speed4 - gravity*(gravity*x*x + 2*y*speed2);
	
	# No solution
	if root < 0:
		print("no solution")
		return Vector3.ZERO
	
	root = sqrt(root);
	
	
	var lowAng := atan2(speed2 - root, gx)
	var highAng = atan2(speed2 + root, gx)
	var numSolutions : int = 2 if lowAng != highAng else 1
	
	var groundDir := diffXZ.normalized()
	s0 = groundDir * cos(lowAng) * proj_speed + Vector3.UP * sin(lowAng) * proj_speed
	
	if numSolutions > 1:
		_s1 = groundDir * cos(highAng) * proj_speed + Vector3.UP * sin(highAng) * proj_speed
	
	return s0



 #, out Vector3 s0, out Vector3 s1
static func solve_ballistic_arc_velocity(proj_pos : Vector3, proj_speed : float, target_pos : Vector3, target_velocity : Vector3, gravity : float = 9.8) -> Vector3:
	
	# Initialize output parameters
	var s0 := Vector3.ZERO;
	var _s1 := Vector3.ZERO;
	
	"""
        // Derivation 
        //
        //  For full derivation see: blog.forrestthewoods.com
        //  Here is an abbreviated version.
        //
        //  Four equations, four unknowns (solution.x, solution.y, solution.z, time):
        //
        //  (1) proj_pos.x + solution.x*time = target_pos.x + target_vel.x*time
        //  (2) proj_pos.y + solution.y*time + .5*G*t = target_pos.y + target_vel.y*time
        //  (3) proj_pos.z + solution.z*time = target_pos.z + target_vel.z*time
        //  (4) proj_speed^2 = solution.x^2 + solution.y^2 + solution.z^2
        //
        //  (5) Solve for solution.x and solution.z in equations (1) and (3)
        //  (6) Square solution.x and solution.z from (5)
        //  (7) Solve solution.y^2 by plugging (6) into (4)
        //  (8) Solve solution.y by rearranging (2)
        //  (9) Square (8)
        //  (10) Set (8) = (7). All solution.xyz terms should be gone. Only time remains.
        //  (11) Rearrange 10. It will be of the form a*^4 + b*t^3 + c*t^2 + d*t * e. This is a quartic.
        //  (12) Solve the quartic using SolveQuartic.
        //  (13) If there are no positive, real roots there is no solution.
        //  (14) Each positive, real root is one valid solution
        //  (15) Plug each time value into (1) (2) and (3) to calculate solution.xyz
        //  (16) The end.
	"""
	var G := gravity
	
	var A := proj_pos.x
	var B := proj_pos.y
	var C := proj_pos.z
	var M := target_pos.x
	var N := target_pos.y
	var O := target_pos.z
	var P := target_velocity.x
	var Q := target_velocity.y
	var R := target_velocity.z
	var S := proj_speed
	
	var H := M - A
	var J := O - C
	var K := N - B
	var L := -0.5 * G
	
	# Quartic Coeffecients
	var c0 := L * L
	var c1 := 2 * Q * L
	var c2 := Q*Q + 2*K*L - S*S + P*P + R*R
	var c3 := 2*K*Q + 2*H*P + 2*J*R
	var c4 := K*K + H*H + J*J
	
	# Solve quartic
	#double[] times = new double[4];
	var times := []
	times.resize(4)
	var _numTimes : int = solve_quartic(c0, c1, c2, c3, c4, times)
	
	# Sort so faster collision is found first
	times.sort()
	
	# Plug quartic solutions into base equations
	# There should never be more than 2 positive, real roots.
	var solutions = []
	solutions.resize(2)
	solutions[0] = Vector3.ZERO
	solutions[1] = Vector3.ZERO
	
	var numSolutions := 0
	
	#for (int i = 0; i < numTimes && numSolutions < 2; ++i) {
	
	for index in range( times.size() ):
		
		if numSolutions >= 2:
			break
		
		var t : float = times[index]
		if is_nan(t) or t <= 0:
			continue
		
		solutions[numSolutions].x = float((H+P*t)/t)
		solutions[numSolutions].y = float((K+Q*t-L*t*t)/ t)
		solutions[numSolutions].z = float((J+R*t)/t)
		numSolutions += 1
	
	
	
	# Write out solutions
	if numSolutions > 0:
		s0 = solutions[0]
	if numSolutions > 1:
		_s1 = solutions[1]
	
	#return numSolutions
	return s0




"""
# , out Vector3 fire_velocity, out float gravity, out Vector3 impact_point
static func solve_ballistic_arc_lateral(proj_pos : Vector3, lateral_speed : float, target : Vector3, target_velocity : Vector3, max_height_offset : float) -> Vector3:
	
	# Handling these cases is up to your project's coding standards
	assert(proj_pos != target && lateral_speed > 0, "fts.solve_ballistic_arc_lateral called with invalid data");
	
	# Initialize output variables
	var fire_velocity := Vector3.ZERO;
	var gravity = 0.0;
	var impact_point := Vector3.ZERO;
	
	# Ground plane terms
	var targetVelXZ := Vector3(target_velocity.x, 0.0, target_velocity.z)
	var diffXZ := target - proj_pos;
	diffXZ.y = 0;
	
	# Derivation
	# (1) Base formula: |P + V*t| = S*t
	# (2) Substitute variables: |diffXZ + targetVelXZ*t| = S*t
	# (3) Square both sides: Dot(diffXZ,diffXZ) + 2*Dot(diffXZ, targetVelXZ)*t + Dot(targetVelXZ, targetVelXZ)*t^2 = S^2 * t^2
	# (4) Quadratic: (Dot(targetVelXZ,targetVelXZ) - S^2)t^2 + (2*Dot(diffXZ, targetVelXZ))*t + Dot(diffXZ, diffXZ) = 0
	
	var c0 := targetVelXZ.dot(targetVelXZ) - lateral_speed*lateral_speed
	var c1 := 2.0 * diffXZ.dot(targetVelXZ)
	var c2 := diffXZ.dot(diffXZ)
	
	# float c0 = Vector3.Dot(targetVelXZ, targetVelXZ) - lateral_speed*lateral_speed;
	# float c1 = 2f * Vector3.Dot(diffXZ, targetVelXZ);
	#float c2 = Vector3.Dot(diffXZ, diffXZ);
	double t0, t1;
	int n = fts.SolveQuadric(c0, c1, c2, out t0, out t1);

        // pick smallest, positive time
        bool valid0 = n > 0 && t0 > 0;
        bool valid1 = n > 1 && t1 > 0;
            
        float t;
        if (!valid0 && !valid1)
            return false;
        else if (valid0 && valid1)
            t = Mathf.Min((float)t0, (float)t1);
        else
            t = valid0 ? (float)t0 : (float)t1;

        // Calculate impact point
        impact_point = target + (target_velocity*t);

        // Calculate fire velocity along XZ plane
        Vector3 dir = impact_point - proj_pos;
        fire_velocity = new Vector3(dir.x, 0f, dir.z).normalized * lateral_speed;

        // Solve system of equations. Hit max_height at t=.5*time. Hit target at t=time.
        //
        // peak = y0 + vertical_speed*halfTime + .5*gravity*halfTime^2
        // end = y0 + vertical_speed*time + .5*gravity*time^s
        // Wolfram Alpha: solve b = a + .5*v*t + .5*g*(.5*t)^2, c = a + vt + .5*g*t^2 for g, v
        float a = proj_pos.y;       // initial
        float b = Mathf.Max(proj_pos.y, impact_point.y) + max_height_offset;  // peak
        float c = impact_point.y;   // final

        gravity = -4*(a - 2*b + c) / (t* t);
        fire_velocity.y = -(3*a - 4*b + c) / t;

        return true;
    }
"""
