#include "yaml-cpp/yaml.h"

int main()
{
   YAML::Emitter out;
   out << YAML::BeginMap;
   out << YAML::Key << "key";
   out << YAML::Value << "value";
   out << YAML::Comment("Comment");
   out << YAML::EndMap;
   std::cout << "Here's the output YAML:\n" << out.c_str() << std::endl; 
   return 0;
}
