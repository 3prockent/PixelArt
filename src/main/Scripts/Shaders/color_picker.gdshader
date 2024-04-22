shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 1.0;
uniform vec3 base_color : source_color = vec3(1.0,1.0,1.0);
uniform vec3 outline_color : source_color = vec3(1.0,1.0,1.0);
uniform float amplitude : hint_range(0.0, 1.0) = 0.0;
uniform bool selected = true;

void fragment() {
    vec2 uv = ((UV / -0.5)) + vec2(1,1);

    float
		sdf=length(uv),c=step(sdf,.85),
		
        vB=smoothstep(.1,.9,sin(uv.x+(PI*.5))-.3),
		vBA=vB*sin(TIME*4.)*.1,
        
        fW=(sin(((TIME*2.)+uv.x)*2.)*.05)+vBA,
		bW=(sin(((TIME*-2.)+uv.x)*2.+PI)*.05)-vBA,
		
        fA=(sin(TIME*4.)*.05)*vB,
        
        fP=progress * 2.3 +(sin((TIME)*PI)*.1*amplitude) - 1.1,
		
        fF=step(uv.y,(((fA+fW)*amplitude)+fP))*c ,
		bF=step(uv.y,(((-fA+bW)*amplitude)+fP))*c;

	

	COLOR = vec4(outline_color,(step(sdf,1.)-step(sdf,.9))+
	(clamp(pow((sdf+.01)*((1.-(fF+bF))*c),5.),0.,1.)));

	if (COLOR.a == 0.0){
	COLOR =
		vec4(base_color,
		(fF+(clamp(bF-fF,0.,1.)*.5))+
		clamp(pow((sdf+.01)*((1.-(fF+bF))*c),5.),0.,1.));
	}


}
