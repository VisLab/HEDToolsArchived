from enum import Enum
import re

class XMLSpecials(Enum):
    gt = (r'>',"&gt;")
    lt = (r'<',"&lt;")
    amp = (r'&',"&amp;")
    apos = (r'\'',"&apos;")
    quot = (r'"',"&quot;")

    def plainText(self):
        return self.value[0]

    def xmlText(self):
        return self.value[1]

    def adjustStr(str):
        xml_str = re.sub(XMLSpecials.amp.plainText(),XMLSpecials.amp.xmlText(),str)
        for char in XMLSpecials:
            if char is XMLSpecials.amp:
                continue

            xml_str = re.sub(char.plainText(),char.xmlText(),xml_str)

        return xml_str
