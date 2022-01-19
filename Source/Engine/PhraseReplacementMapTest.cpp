// Copyright (c) 2022 and onwards The McBopomofo Authors.
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.

#include <cstdio>
#include <filesystem>
#include <string>

#include "PhraseReplacementMap.h"
#include "gtest/gtest.h"

namespace McBopomofo {

TEST(PhraseReplacementMapTest, LenientReading)
{
    std::string tmp_name
        = std::string(std::filesystem::temp_directory_path()) + "test.txt";

    FILE* f = fopen(tmp_name.c_str(), "w");
    ASSERT_NE(f, nullptr);

    fprintf(f, "key value\n");
    fprintf(f, "key2\n"); // error line
    fprintf(f, "key3 value2\n");
    int r = fclose(f);
    ASSERT_EQ(r, 0);

    PhraseReplacementMap map;
    map.open(tmp_name.c_str());
    ASSERT_EQ(map.valueForKey("key"), "value");
    ASSERT_EQ(map.valueForKey("key2"), "");

    // key2 causes parsing error, and the line that has key3 won't be parsed.
    ASSERT_EQ(map.valueForKey("key3"), "");

    r = remove(tmp_name.c_str());
    ASSERT_EQ(r, 0);
}

} // namespace McBopomofo
