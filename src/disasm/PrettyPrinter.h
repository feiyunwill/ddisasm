#pragma once

#include <map>
#include <string>
#include <cstdint>
#include <vector>
#include <list>
#include <iosfwd>

#include "DisasmData.h"

///
/// \class PrettyPrinter
///
/// Port of the prolog pretty printer.
///
class PrettyPrinter
{
public:
	PrettyPrinter();

	void setDebug(bool x);
	bool getDebug() const;

	///
	/// Pretty print to the given file name.
	///
	std::string prettyPrint(DisasmData* x);

protected:
	void printBar(bool heavy = true);
	void printBlock(const DisasmData::Block& x);
	void printEA(uint64_t ea);
	void printFunctionHeader(uint64_t ea);
	void printHeader();
	void printInstruction(uint64_t ea);
	void printInstructionNop();
	void printLabel(uint64_t ea);
	void printSectionHeader(const std::string& x);

	void condPrintGlobalSymbol(uint64_t ea);
	void condPrintSectionHeader(const DisasmData::Block& x);

	bool skipEA(const uint64_t x) const;

private:
	DisasmData* disasm{nullptr};
	std::stringstream ofs;

	std::vector<std::string> asm_skip_section;
	std::vector<std::string> asm_skip_function;

	bool debug{false};
};
