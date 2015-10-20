// PUT_VREP_REMOTEAPI_COPYRIGHT_NOTICE_HERE

package coppelia;

@SuppressWarnings({ "unqualified-field-access", "javadoc" })
public class FloatW
{
    float w;

    public FloatW(float f)
    {
        w = f;
    }

    public void setValue(float i)
    {
        w = i;
    }

    public float getValue()
    {
        return w;
    }
}