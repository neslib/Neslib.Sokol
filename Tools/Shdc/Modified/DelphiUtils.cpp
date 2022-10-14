#include "DelphiUtils.h"

namespace shdc {
	std::string DelphiIdent(const std::string & str)
	{
		std::string s(str);
		std::string::size_type len = s.size();

		if (len > 0)
		{
			if (::islower(s[0])) 
				s[0] = (char) ::toupper(s[0]);
		}

		int si = 0;
		int di = 0;
		int newLen = len;
		int wordLen = 0;
		while (si < len)
		{
			if ((s[si] == '_') && ((si + 1) < len))
			{
				if (wordLen == 2) {
					// Assume previous word is a 2-letter acronym. Upper case it
					if (::islower(s[si - 1]))
						s[di - 1] = ::toupper(s[si - 1]);
				}

				++si;
				if (::islower(s[si]))
					s[di] = ::toupper(s[si]);
				else
					s[di] = s[si];

				--newLen;
				wordLen = 0;
			}
			else
			{
				s[di] = s[si];
				++wordLen;
			}

			++si;
			++di;
		}

		if (newLen != len)
			s.resize(newLen);

		return s;
	}
}