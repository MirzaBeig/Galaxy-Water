
using UnityEngine;

// MB: Simple procedural audio generator.
// Generates a pure sine wave/tone at a given frequency.

public class SimpleAudioGenerator : MonoBehaviour
{
    int outputSampleRate;
    const float TAU = Mathf.PI * 2.0f;

    // Continous phase = continuous tone.

    float phase = 0.0f;

    // Careful, this can be very loud!

    [Range(0.0f, 1.0f)]
    public float amplitude = 0.5f;

    // ~Typical range of human hearing is 20Hz to 20kHz.

    [Range(100.0f, 8000.0f)]
    public float frequency = 440.0f; // A4.

    // ...

    float phaseStep;
    Vector2 mouse;

    // ...

    void Start()
    {
        outputSampleRate = AudioSettings.outputSampleRate;
    }

    void Update()
    {
        // Step per signal progression.

        phaseStep = (frequency * TAU) / outputSampleRate;

        // Normalized mouse position, coordinates.

        Vector2 resolution = new(Screen.width, Screen.height);
        mouse = Input.mousePosition / resolution;
    }

    // ShaderToy: https://www.shadertoy.com/view/33cyWN

    // Gist: https://x.com/TheMirzaBeig/status/1824041071690527134
    // Stylized Fire (Circle Waves): https://x.com/TheMirzaBeig/status/1866512552793919617

    void OnAudioFilterRead(float[] data, int channels)
    {
        for (int i = 0; i < data.Length; i += channels)
        {
            float sinPhase = Mathf.Sin(phase);
            //float cosPhase = Mathf.Cos(phase);

            float sinPhase_abs = Mathf.Abs(sinPhase);
            float sinPhase_sign = Mathf.Sign(sinPhase);

            // 0.0 = square.
            // 0.5 = circle.
            // 1.0 = sine.

            float squareCircleSineBlend = mouse.x;

            float wave = Mathf.Pow(sinPhase_abs, squareCircleSineBlend) * sinPhase_sign;

            wave *= amplitude;

            for (int j = 0; j < channels; j++)
            {
                data[i + j] = wave;
            }

            phase += phaseStep;

            // Phase = [0.0f, TAU).

            if (phase > TAU)
            {
                phase -= TAU;
            }
        }
    }
}
