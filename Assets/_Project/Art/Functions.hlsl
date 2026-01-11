// Common.

float2 Rotate2D(float2 v, float a)
{
	float s = sin(a);
	float c = cos(a);
    
	float2x2 m = float2x2(c, -s, s, c);
    
	return mul(m, v);
}

// Grid. (_float because I made this for Shader Graph, then used ASE).

void Grid_float(float2 uv, float thickness, out float output)
{
    // Calculate distance to nearest grid line for each axis. 
    
    float2 grid = abs(frac(uv - 0.5f) - 0.5f) / fwidth(uv);
    float lineMin = min(grid.x, grid.y);
    
    // Convert thickness to grid space and apply antialiasing.
    
    output = 1.0f - min(lineMin / thickness, 1.0f);

    // Lol. Do something about this later?
    
    output = 1.0 - step(0.4, 1.0 - output);
}

// Water.

float3 SineWave
(
    float3 position,
    float3 center,

    float amplitude,
    float frequency,

    float3 animation,
    float rotation,

    out float3 normalTS)
{
    rotation = radians(rotation);

    // Rotate around center (object/transform position, offset).

    position -= center;
    position.xz = Rotate2D(position.xz, rotation);
    position += center;

    // Apply frequency and animation.

    position *= frequency;
    position -= animation * _Time.y;

    // Calculate phase.    

    float phase = position.x;

    float sinPhase = sin(phase);
    float cosPhase = cos(phase);

    // Vertex offset.

    float3 wave = 0.0;

    wave.y = sinPhase * amplitude;

    // Calculate normal.

    float frequencyAmplitude = frequency * amplitude;
    float slope = cosPhase * frequencyAmplitude;

    // Rotate back.

    float normalX = slope * cos(-rotation);
    float normalY = slope * sin(-rotation);
    
    // Should the z-term be a parameter/variable?

    normalTS = normalize(float3(normalX, normalY, 1.0f));

    // Output.

    return wave;
}

// Trochoid[al] wave == sine, when steepness == 0.0f.
// https://x.com/TheMirzaBeig/status/2009864679557087441

float3 GerstnerWave
(
    float3 position,
    float3 center,

    float amplitude,
    float frequency,

    float steepness,
    float3 animation,

    float rotation,

    out float3 normalTS
)
{
    rotation = radians(rotation);

    // Rotate around center (object/transform position, offset).

    position -= center;
    position.xz = Rotate2D(position.xz, rotation);
    position += center;

    // Apply frequency and animation.

    position *= frequency;
    position -= animation * _Time.y;

    // Calculate phase.    

    float phase = position.x;

    float sinPhase = sin(phase);
    float cosPhase = cos(phase);

    // Local wave offset.

    float3 localWave = 0.0;

    localWave.x = cosPhase * (steepness * amplitude);
    localWave.y = sinPhase * amplitude;

    // Rotate wave back into original space.

    float2 rotatedXZ = Rotate2D(float2(localWave.x, localWave.z), -rotation);
    float3 wave = float3(rotatedXZ.x, localWave.y, rotatedXZ.y);

    // Calculate normal.

    float frequencyAmplitude = frequency * amplitude;
    float slope = cosPhase * frequencyAmplitude;

    // Z-term.
    
    float vertical = 1.0f - (sinPhase * (steepness * frequencyAmplitude));

    // Rotate normal back.

    float normalX = slope * cos(-rotation);
    float normalY = slope * sin(-rotation);

    normalTS = normalize(float3(normalX, normalY, vertical));

    // Output.

    return wave;
}