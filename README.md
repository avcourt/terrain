## Terrain Shader
***A procedural terrain shader using Perlin noise in GLSL*** 

![ShaderToy screenshot](img/screenshot.png)

This shader has 3 main components: 
- The terrain generation itself, which uses a 2-d noise generating algorithm found [here](http://shadertoy.wikia.com/wiki/Noise) 
- Ray casting to determine what the camera is seeing:
    - only three materials: `rock`, `sky`, `ice` 
- The camera itself: there’s no way to see all your procedurally generated terrain if the camera doesn’t move anywhere, so I programmed a very basic camera fly-over effect by simply moving the camera position along the `Z-axis`.

For simplicity I considered only three “materials”: 

 1. the rocks of the terrain
 2. ice/snow/water, or whatever you’d like to call it, filling the low spots of the terrain.(I settled on `ICE` for the variable names in *GLSL*)
 3. `SKY` for everything else. 
 
 Height was considered the distance above(and below, using a range) 0 in the `y-axis`. Once the noise was generated by the noise algorithm, rays were cast from the camera position to determine where the terrain was. Any position that a ray did not intersect (a max distance was also used to limit ray distance) was considered sky. The actual mapping of colour was done by casting rays and returning the height of the intersected ray. With these height values adding in the ice would be easy. Anything within a certain `Y-value` was coloured as ice, anything outside (that a ray intersected) as rock, and anything else remaining must be sky, and was coloured accordingly.

### Lighting
I used a simple ambient lighting that varied slightly in the range `[0-1]` based on the calculated normal. For the diffuse light I took the dot product of the surface normal and the light position vector. One of the simplest reflection models out there. This very simple lighting equation does have some drawbacks however; mainly, the light value does not vary with the distance from the camera. (Inverse square law!). To fix this problem I used the classic fog effect hack to smooth out the appearance of distance surfaces. This lighting equation does create a realistic enough shadow effect however, based on the direction of the light from the "sun". With this being the case, I did not worry about implementing any sort of shadow casting, as there are no real “*obects*” to cast any shadows on the terrain surface anyway. I constrained the normals using `OpenGL.clamp()` in case my equations didn’t properly constrain the values on their own. I didn’t notice a change without `clamp`, but decided to use the constraints in case experimenting with the constants at the top of the program caused different behaviour.

### Fog
As mentioned above, to make the brightness of distant terrain look more natural, I decided to take the edge off far away mountains by adding some fog to the scene. I opted for a uniform fog.  I found a great explanation [here](http://in2gpu.com/2014/07/22/create-fog-shader/).

Overall, with only 3 distinct materials I’m quite pleased by the final effect. Certainly more material ranges could be added. For example, green trees, water instead of snow. Perhaps snow on the tops of mountains. Simulating the sun by have a brighter section of the sky etc. Perhaps using the terrain/noise function with different weights/values could be used to simulate trees, or rolling hills.

### Run
To run, simply copy the code in `terrain.glsl` and paste into a new shadertoy at [ShaderToy](https://www.shadertoy.com/new)
