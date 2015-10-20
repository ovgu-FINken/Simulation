// PUT_VREP_REMOTEAPI_COPYRIGHT_NOTICE_HERE

package coppelia;

@SuppressWarnings({ "unqualified-field-access", "javadoc" })
public class StringW
{
    String w;

    public StringW(String s)
    {
        w = new String(s);
    }

    public void setValue(String s)
    {
        w = new String(s);
    }

    public String getValue()
    {
        return w;
    }
}