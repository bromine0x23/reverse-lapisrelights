package xyz.bromine0x23.lapisrelights.il2cpp;

import lombok.Data;

import java.util.List;

/// @author <a href="mailto:bromine0x23@gmail.com">Bromine0x23</>
public class GlobalMetadata {

	private Header header;

	private List<String> stringLiterals;

	public static @Data class Header {
		private int sanity;
		private int version;
		private int stringLiteralOffset; // string data for managed code
		private int stringLiteralCount;
		private int stringLiteralDataOffset;
		private int stringLiteralDataCount;
		private int stringOffset; // string data for metadata
		private int stringCount;
		private int eventsOffset; // Il2CppEventDefinition
		private int eventsCount;
		private int propertiesOffset; // Il2CppPropertyDefinition
		private int propertiesCount;
		private int methodsOffset; // Il2CppMethodDefinition
		private int methodsCount;
		private int parameterDefaultValuesOffset; // Il2CppParameterDefaultValue
		private int parameterDefaultValuesCount;
		private int fieldDefaultValuesOffset; // Il2CppFieldDefaultValue
		private int fieldDefaultValuesCount;
		private int fieldAndParameterDefaultValueDataOffset; // uint8_t
		private int fieldAndParameterDefaultValueDataCount;
		private int fieldMarshaledSizesOffset; // Il2CppFieldMarshaledSize
		private int fieldMarshaledSizesCount;
		private int parametersOffset; // Il2CppParameterDefinition
		private int parametersCount;
		private int fieldsOffset; // Il2CppFieldDefinition
		private int fieldsCount;
		private int genericParametersOffset; // Il2CppGenericParameter
		private int genericParametersCount;
		private int genericParameterConstraintsOffset; // TypeIndex
		private int genericParameterConstraintsCount;
		private int genericContainersOffset; // Il2CppGenericContainer
		private int genericContainersCount;
		private int nestedTypesOffset; // TypeDefinitionIndex
		private int nestedTypesCount;
		private int interfacesOffset; // TypeIndex
		private int interfacesCount;
		private int vtableMethodsOffset; // EncodedMethodIndex
		private int vtableMethodsCount;
		private int interfaceOffsetsOffset; // Il2CppInterfaceOffsetPair
		private int interfaceOffsetsCount;
		private int typeDefinitionsOffset; // Il2CppTypeDefinition
		private int typeDefinitionsCount;
		private int imagesOffset; // Il2CppImageDefinition
		private int imagesCount;
		private int assembliesOffset; // Il2CppAssemblyDefinition
		private int assembliesCount;
		private int metadataUsageListsOffset; // Il2CppMetadataUsageList
		private int metadataUsageListsCount;
		private int metadataUsagePairsOffset; // Il2CppMetadataUsagePair
		private int metadataUsagePairsCount;
		private int fieldRefsOffset; // Il2CppFieldRef
		private int fieldRefsCount;
		private int referencedAssembliesOffset; // int32_t
		private int referencedAssembliesCount;
		private int attributesInfoOffset; // Il2CppCustomAttributeTypeRange
		private int attributesInfoCount;
		private int attributeTypesOffset; // TypeIndex
		private int attributeTypesCount;
		private int unresolvedVirtualCallParameterTypesOffset; // TypeIndex
		private int unresolvedVirtualCallParameterTypesCount;
		private int unresolvedVirtualCallParameterRangesOffset; // Il2CppRange
		private int unresolvedVirtualCallParameterRangesCount;
		private int windowsRuntimeTypeNamesOffset; // Il2CppWindowsRuntimeTypeNamePair
		private int windowsRuntimeTypeNamesSize;
		private int exportedTypeDefinitionsOffset; // TypeDefinitionIndex
		private int exportedTypeDefinitionsCount;
	}

	public static @Data class StringLiteral {
		public static final int  BYTES = 8;
		private             long length; // uint32_t
		private             int  dataIndex; // StringLiteralIndex
	}

	public static @Data class EventDefinition {
		public static final int BYTES = 24;
		private             int nameIndex; // StringIndex
		private             int typeIndex; // TypeIndex
		private             int add; // MethodIndex
		private             int remove; // MethodIndex
		private             int raise; // MethodIndex
		private             int token; // uint32_t
	}

	public static @Data class PropertyDefinition {
		public static final int BYTES = 20;
		private             int nameIndex; // StringIndex
		private             int get; // MethodIndex
		private             int set; // MethodIndex
		private             int attrs; // uint32_t
		private             int token; // uint32_t
	}

	public static @Data class MethodDefinition {
		public static final int BYTES = 32;
		private             int nameIndex; // StringIndex
		private             int declaringType; // TypeDefinitionIndex
		private             int returnType; // TypeIndex
		private             int parameterStart; // ParameterIndex
		private             int genericContainerIndex; // GenericContainerIndex
		private             int token; // uint32_t
		private             int flags; // uint16_t
		private             int iflags; // uint16_t
		private             int slot; // uint16_t
		private             int parameterCount; // uint16_t
	}

	public static @Data class ParameterDefaultValue {
		public static final int BYTES = 12;
		private             int parameterIndex; // ParameterIndex
		private             int typeIndex; // TypeIndex
		private             int dataIndex; // DefaultValueDataIndex
	}

	public static @Data class FieldDefaultValue {
		public static final int BYTES = 12;
		private             int fieldIndex; // FieldIndex
		private             int typeIndex; // TypeIndex
		private             int dataIndex; // DefaultValueDataIndex
	}

	public static @Data class FieldMarshaledSize {
		public static final int BYTES = 12;
		private             int fieldIndex; // FieldIndex
		private             int typeIndex; // TypeIndex
		private             int size; // int32_t
	}

	public static @Data class ParameterDefinition {
		public static final int  BYTES = 12;
		private             int  nameIndex; // StringIndex
		private             long token; // uint32_t
		private             int  typeIndex; // TypeIndex
	}

	public static @Data class FieldDefinition {
		public static final int  BYTES = 12;
		private             int  nameIndex; // StringIndex
		private             int  typeIndex; // TypeIndex
		private             long token; // uint32_t
	}

	public static @Data class GenericParameter {
		public static final int   BYTES = 16;
		private             int   ownerIndex; // GenericContainerIndex
		private             int   nameIndex; // StringIndex
		private             short constraintsStart; // GenericParameterConstraintIndex
		private             short constraintsCount; // int16_t
		private             int   num; // uint16_t
		private             int   flags; // uint16_t
	}

	public static @Data class GenericContainer {
		public static final int BYTES = 16;
		private             int ownerIndex; // int32_t
		private             int typeArgc; // int32_t
		private             int isMethod; // int32_t
		private             int genericParameterStart; // GenericParameterIndex
	}

	public static @Data class InterfaceOffsetPair {
		public static final int BYTES = 8;
		private             int interfaceTypeIndex; // TypeIndex
		private             int offset; // int32_t
	}

	public static @Data class TypeDefinition {
		public static final int  BYTES = 92;
		private             int  nameIndex; // StringIndex
		private             int  namespaceIndex; // StringIndex
		private             int  byvalTypeIndex; // TypeIndex
		private             int  byrefTypeIndex; // TypeIndex
		private             int  declaringTypeIndex; // TypeIndex
		private             int  parentIndex; // TypeIndex
		private             int  elementTypeIndex; // TypeIndex
		private             int  genericContainerIndex; // GenericContainerIndex
		private             long flags; // uint32_t
		private             int  fieldStart; // FieldIndex
		private             int  methodStart; // MethodIndex
		private             int  eventStart; // EventIndex
		private             int  propertyStart; // PropertyIndex
		private             int  interfacesStart; // InterfacesIndex
		private             int  vtableStart; // VTableIndex
		private             int  interfaceOffsetsStart; // InterfacesIndex
		private             int  methodCount; // uint16_t
		private             int  propertyCount; // uint16_t
		private             int  fieldCount; // uint16_t
		private             int  eventCount; // uint16_t
		private             int  nestedTypeCount; // uint16_t
		private             int  vtableCount; // uint16_t
		private             int  interfacesCount; // uint16_t
		private             int  interfaceOffsetsCount; // uint16_t
		private             long bitfield; // uint32_t
		private             long token; // uint32_t
	}

	public static @Data class ImageDefinition {
		public static final int  BYTES = 40;
		private             int  nameIndex; // StringIndex
		private             int  assemblyIndex; // AssemblyIndex
		private             int  typeStart; // TypeDefinitionIndex
		private             long typeCount; // uint32_t
		private             int  exportedTypeStart; // TypeDefinitionIndex
		private             long exportedTypeCount; // uint32_t
		private             int  entryPointIndex; // MethodIndex
		private             long token; // uint32_t
		private             int  customAttributeStart; // CustomAttributeIndex
		private             long customAttributeCount; // uint32_t
	}

	public static @Data class AssemblyDefinition {
		public static final int            BYTES = 64;
		private             int            imageIndex; // ImageIndex
		private             long           token; // uint32_t
		private             int            referencedAssemblyStart; // int32_t
		private             int            referencedAssemblyCount; // int32_t
		private             NameDefinition name; // Il2CppAssemblyNameDefinition

		public static @Data class NameDefinition {
			public static final int     PUBLIC_KEY_BYTE_LENGTH = 8;
			private             int     nameIndex; // StringIndex
			private             int     cultureIndex; // StringIndex
			private             int     publicKeyIndex; // StringIndex
			private             long    hashAlg; // uint32_t
			private             int     hashLen; // int32_t
			private             long    flags; // uint32_t
			private             int     major; // int32_t
			private             int     minor; // int32_t
			private             int     build; // int32_t
			private             int     revision; // int32_t
			private             short[] publicKeyToken         = new short[PUBLIC_KEY_BYTE_LENGTH]; // uint8_t[PUBLIC_KEY_BYTE_LENGTH]
		}
	}

	public static @Data class MetadataUsageList {
		public static final int  BYTES = 8;
		private             long start; // uint32_t
		private             long count; // uint32_t
	}

	public static @Data class MetadataUsagePair {
		public static final int  BYTES = 8;
		private             long destinationIndex; // uint32_t
		private             long encodedSourceIndex; // uint32_t
	}

	public static @Data class FieldRef {
		public static final int BYTES = 8;
		private             int typeIndex; // TypeIndex
		private             int fieldIndex; // FieldIndex
	}

	public static @Data class CustomAttributeTypeRange {
		public static final int  BYTES = 12;
		private             long token; // uint32_t
		private             int  start; // int32_t
		private             int  count; // int32_t
	}

	public static @Data class UnresolvedVirtualCallParameterRange {
		public static final int BYTES = 8;
		private             int start; // int32_t
		private             int length; // int32_t
	}

	public static @Data class WindowsRuntimeTypeNamePair {
		public static final int BYTES = 8;
		private             int nameIndex; // StringIndex
		private             int typeIndex; // TypeIndex
	}

}

